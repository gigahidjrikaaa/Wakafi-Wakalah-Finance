// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Use a recent Solidity version

// Import necessary contracts from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Or AccessControl for more roles
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol"; // Useful for tracking approved assets
import "forge-std/console.sol"; // For debugging with console.log during tests

/**
 * @title WakalahPool
 * @notice A basic implementation of a Sharia-compliant yield pool based on Wakalah.
 * Users deposit approved ERC20 assets, the protocol manages them (conceptually),
 * and users can withdraw principal + profit share, minus fees (Ujrah).
 * WARNING: Profit calculation is highly simplified/placeholder in this version.
 * This contract requires thorough testing and auditing before any real-world use.
 */
contract WakalahPool is Ownable, ReentrancyGuard { // Inherit Ownable & ReentrancyGuard
    using SafeERC20 for IERC20; // Use SafeERC20 library for safe ERC20 interactions
    using EnumerableSet for EnumerableSet.AddressSet; // Use EnumerableSet for managing approved assets

    // --- State Variables ---

    /**
     * @notice Tracks the principal amount deposited by each user for each specific asset.
     * @dev mapping(userAddress => mapping(assetAddress => principalAmount))
     */
    mapping(address => mapping(address => uint256)) public userPrincipal;

    /**
     * @notice Tracks the total principal amount deposited for each specific asset across all users.
     * @dev mapping(assetAddress => totalPrincipalAmount)
     */
    mapping(address => uint256) public totalPrincipalByAsset;

    /**
     * @notice A set storing the addresses of ERC20 tokens approved for deposit.
     * @dev Using EnumerableSet allows iteration and efficient add/remove/contains checks.
     * Managed by the contract owner.
     */
    EnumerableSet.AddressSet private approvedAssets;

    /**
     * @notice Deposit fee charged as basis points (1/100th of 1%). E.g., 100 = 1%.
     */
    uint256 public depositFeeBps;

    /**
     * @notice Withdrawal fee charged as basis points on the total withdrawal amount (principal + profit).
     */
    uint256 public withdrawalFeeBps;
    // Note: A periodic Management Fee (AUM-based) is harder to implement reliably on-chain
    // without complex pull mechanisms or snapshots, so omitted for simplicity here.

    /**
     * @notice The address designated to receive the collected Ujrah (fees).
     */
    address public feeRecipient;

    // --- Events ---
    // Events are crucial for off-chain services (like your backend/indexer) to track activity.

    /** @notice Emitted when an asset's approval status is changed by the owner. */
    event AssetApproved(address indexed asset, bool isApproved);
    /** @notice Emitted when a user successfully deposits funds. */
    event Deposit(address indexed user, address indexed asset, uint256 netAmountDeposited, uint256 feeAmount);
    /** @notice Emitted when a user successfully withdraws funds. */
    event Withdrawal(address indexed user, address indexed asset, uint256 principalAmountWithdrawn, uint256 profitShareAmount, uint256 feeAmount);
    /** @notice Emitted when fees are transferred to the fee recipient. */
    event FeesCollected(address indexed recipient, address indexed asset, uint256 amount);
    /** @notice Emitted when profit is recorded (for simplified/placeholder profit model). */
    event ProfitRecorded(address indexed asset, uint256 profitAmount);
    /** @notice Emitted when fee basis points are updated. */
    event FeeBpsUpdated(uint256 depositFeeBps, uint256 withdrawalFeeBps);
    /** @notice Emitted when the fee recipient address is updated. */
    event FeeRecipientUpdated(address indexed newRecipient);


    // --- Modifiers ---

    /**
     * @notice Modifier to ensure that an operation is only performed with an approved asset.
     * @param _asset The address of the ERC20 token to check.
     */
    modifier onlyApprovedAsset(address _asset) {
        require(approvedAssets.contains(_asset), "WakalahPool: Asset not approved");
        _; // Continue execution if the asset is approved
    }

    // --- Constructor ---

    /**
     * @notice Initializes the contract upon deployment.
     * @param _initialOwner The address that will have ownership (admin rights) of the contract.
     * @param _feeRecipient The address where collected fees (Ujrah) will be sent.
     */
    constructor(address _initialOwner, address _feeRecipient) Ownable(_initialOwner) {
        require(_feeRecipient != address(0), "WakalahPool: Invalid fee recipient");
        feeRecipient = _feeRecipient;
        // Initialize fees (example: 0.1% = 10 bps for deposit, 0.1% = 10 bps for withdrawal)
        depositFeeBps = 10;
        withdrawalFeeBps = 10;
        emit FeeBpsUpdated(depositFeeBps, withdrawalFeeBps);
        emit FeeRecipientUpdated(_feeRecipient);
    }

    // --- Admin Functions (Owner Controlled) ---
    // These functions can only be called by the address set as the owner via Ownable.

    /**
     * @notice Allows the owner to approve or disapprove an ERC20 token for deposits.
     * @param _asset The address of the ERC20 token.
     * @param _isApproved True to approve, false to disapprove.
     */
    function setApprovedAsset(address _asset, bool _isApproved) external onlyOwner {
        require(_asset != address(0), "WakalahPool: Invalid asset address");
        if (_isApproved) {
            approvedAssets.add(_asset);
        } else {
            // Removing an asset needs careful consideration.
            // Should it prevent future deposits only? Or trigger something else?
            // For simplicity, this just removes it from the approved set.
            // Ensure off-chain systems / UI handle this appropriately.
            approvedAssets.remove(_asset);
        }
        emit AssetApproved(_asset, _isApproved);
    }

    /**
     * @notice Allows the owner to update the fee percentages (in basis points).
     * @param _depositFeeBps New deposit fee basis points.
     * @param _withdrawalFeeBps New withdrawal fee basis points.
     */
    function setFeeBps(uint256 _depositFeeBps, uint256 _withdrawalFeeBps) external onlyOwner {
        // Add sanity checks, e.g., require(_depositFeeBps <= 1000, "Fee too high"); // Max 10% example
        require(_depositFeeBps <= 10000, "WakalahPool: Deposit fee cannot exceed 100%"); // Prevent > 100% fee
        require(_withdrawalFeeBps <= 10000, "WakalahPool: Withdrawal fee cannot exceed 100%"); // Prevent > 100% fee

        depositFeeBps = _depositFeeBps;
        withdrawalFeeBps = _withdrawalFeeBps;
        emit FeeBpsUpdated(depositFeeBps, withdrawalFeeBps);
    }

    /**
     * @notice Allows the owner to change the address where fees are sent.
     * @param _newRecipient The new address to receive fees.
     */
    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "WakalahPool: Invalid fee recipient");
        feeRecipient = _newRecipient;
        emit FeeRecipientUpdated(_newRecipient);
    }

    /**
     * @notice Placeholder function for the owner/admin to record profit generated off-chain or by integrated strategies.
     * @dev In a real system, this would likely be replaced by automated profit distribution from integrated yield sources.
     * This simplified version primarily emits an event for off-chain systems.
     * A more complex version might update internal metrics used for calculating withdrawal amounts.
     * @param _asset The asset for which profit is recorded.
     * @param _profitAmount The amount of profit generated in terms of the asset.
     */
    function recordProfit(address _asset, uint256 _profitAmount) external onlyOwner onlyApprovedAsset(_asset) {
        // TODO: Implement actual profit distribution logic or internal value tracking.
        // For now, just emitting an event.
        emit ProfitRecorded(_asset, _profitAmount);
    }

    // --- Core User Functions ---

    /**
     * @notice Allows a user to deposit an approved ERC20 token into the pool.
     * @dev User must have approved the contract to spend their tokens beforehand (standard ERC20 allowance).
     * @param _asset The address of the approved ERC20 token to deposit.
     * @param _amount The amount of tokens to deposit.
     */
    function deposit(address _asset, uint256 _amount) external nonReentrant onlyApprovedAsset(_asset) {
        require(_amount > 0, "WakalahPool: Deposit amount must be positive");

        // Calculate fee based on the gross deposit amount
        uint256 feeAmount = (_amount * depositFeeBps) / 10000;
        uint256 netAmount = _amount - feeAmount; // Amount credited to user's principal balance

        // Ensure deposit isn't completely consumed by fee
        require(netAmount > 0, "WakalahPool: Deposit amount too small after fee");

        // --- Checks-Effects-Interactions Pattern ---
        // 1. Effects (Update internal state first)
        userPrincipal[msg.sender][_asset] += netAmount;
        totalPrincipalByAsset[_asset] += netAmount;

        // 2. Interactions (External calls last)
        // Pull tokens from user to this contract
        IERC20(_asset).safeTransferFrom(msg.sender, address(this), _amount);

        // Send fee to recipient (if fee exists)
        if (feeAmount > 0) {
            IERC20(_asset).safeTransfer(feeRecipient, feeAmount);
            emit FeesCollected(feeRecipient, _asset, feeAmount);
        }

        emit Deposit(msg.sender, _asset, netAmount, feeAmount);
    }

    /**
     * @notice Allows a user to withdraw their principal and accrued profit share (simplified) for a specific asset.
     * @param _asset The address of the approved ERC20 token to withdraw.
     * @param _principalAmountToWithdraw The amount of principal the user wishes to withdraw.
     */
    function withdraw(address _asset, uint256 _principalAmountToWithdraw) external nonReentrant onlyApprovedAsset(_asset) {
        require(_principalAmountToWithdraw > 0, "WakalahPool: Withdraw amount must be positive");

        uint256 currentPrincipal = userPrincipal[msg.sender][_asset];
        require(currentPrincipal >= _principalAmountToWithdraw, "WakalahPool: Insufficient principal");

        // --- Profit Calculation (PLACEHOLDER - NEEDS ROBUST IMPLEMENTATION) ---
        // This is highly simplified. A real system needs a fair way to calculate the
        // user's share of the actual profits generated by the pool for that asset.
        // This often involves tracking pool value changes, using shares, or oracles.
        // For this example, we assume profit share is 0 for simplicity.
        // Replace this with actual logic based on your chosen profit tracking model.
        uint256 profitShareAmount = _calculateProfitShare(msg.sender, _asset, _principalAmountToWithdraw); // Use internal function
        // --- End Placeholder Profit Calculation ---

        uint256 totalWithdrawAmountBeforeFee = _principalAmountToWithdraw + profitShareAmount;

        // Calculate fee based on the total amount being withdrawn (principal + profit)
        uint256 feeAmount = (totalWithdrawAmountBeforeFee * withdrawalFeeBps) / 10000;
        uint256 netWithdrawAmount = totalWithdrawAmountBeforeFee - feeAmount;

        // Ensure withdrawal isn't completely consumed by fee
        require(netWithdrawAmount > 0, "WakalahPool: Withdraw amount too small after fee");
        // Ensure the contract physically has enough tokens to send
        require(IERC20(_asset).balanceOf(address(this)) >= netWithdrawAmount, "WakalahPool: Insufficient pool balance for withdrawal");

        // --- Checks-Effects-Interactions Pattern ---
        // 1. Effects (Update internal state first)
        userPrincipal[msg.sender][_asset] -= _principalAmountToWithdraw;
        totalPrincipalByAsset[_asset] -= _principalAmountToWithdraw;
        // TODO: Need to account for reduction in total pool value/profit tracking due to withdrawal

        // 2. Interactions (External calls last)
        // Transfer net amount (principal + profit - fee) to user
        IERC20(_asset).safeTransfer(msg.sender, netWithdrawAmount);

        // Send fee to recipient (if fee exists)
        if (feeAmount > 0) {
            IERC20(_asset).safeTransfer(feeRecipient, feeAmount);
            emit FeesCollected(feeRecipient, _asset, feeAmount);
        }

        emit Withdrawal(msg.sender, _asset, _principalAmountToWithdraw, profitShareAmount, feeAmount);
    }


    // --- Internal Helper Functions ---

    /**
     * @notice Internal function to calculate profit share (Placeholder).
     * @dev Replace with actual profit calculation logic based on pool performance and user's share.
     * This might involve reading internal value-per-share metrics or complex calculations.
     * @param _user The user withdrawing.
     * @param _asset The asset being withdrawn.
     * @param _principalAmount The principal amount being withdrawn.
     * @return profitShare The calculated profit share for this withdrawal.
     */
    function _calculateProfitShare(
        address _user,
        address _asset,
        uint256 _principalAmount
    ) internal view returns (uint256 profitShare) {
        // Silence unused variable warnings for placeholder
        _user;
        _asset;
        _principalAmount;
        // ****** V E R Y S I M P L I F I E D ******
        // In a real system:
        // 1. Determine the total value of the pool for `_asset`.
        // 2. Determine the user's proportional share of the pool based on their principal.
        // 3. Calculate profit = (current value of user's share) - (user's principal).
        // 4. Return the profit corresponding to the `_principalAmount` being withdrawn.
        // This example returns 0 for simplicity.
        profitShare = 0;
        // ****************************************
        return profitShare;
    }


    // --- View Functions ---
    // Public functions to read contract state without making transactions.

    /**
     * @notice Checks if a given asset is approved for deposit.
     * @param _asset The address of the ERC20 token.
     * @return bool True if the asset is approved, false otherwise.
     */
    function isAssetApproved(address _asset) external view returns (bool) {
        return approvedAssets.contains(_asset);
    }

    /**
     * @notice Returns an array of all currently approved asset addresses.
     * @dev Useful for frontends to display deposit options.
     * @return address[] Memory array of approved asset addresses.
     */
    function getApprovedAssets() external view returns (address[] memory) {
        return approvedAssets.values();
    }

    /**
     * @notice Returns the number of approved assets.
     */
    function getApprovedAssetsCount() external view returns (uint256) {
        return approvedAssets.length();
    }

    /**
     * @notice Returns an approved asset address by its index in the set.
     * @dev Useful for paginating or iterating through approved assets off-chain.
     * @param _index The index of the asset in the EnumerableSet.
     * @return address The asset address at the given index.
     */
    function getApprovedAssetAtIndex(uint256 _index) external view returns (address) {
        return approvedAssets.at(_index);
    }

    // Add more view functions as needed:
    function getUserBalance(address _user, address _asset) external view returns (uint256 principal, uint256 estimatedProfitShare) {
        principal = userPrincipal[_user][_asset];
        estimatedProfitShare = _calculateProfitShare(_user, _asset, principal); // Placeholder for actual profit share
    }
    function getTotalPoolValue(address _asset) external view returns (uint256) {
        return totalPrincipalByAsset[_asset]; // Placeholder for actual pool value
    }

    // function getFeeInfo() external view returns (uint256 depositFeeBps, uint256 withdrawalFeeBps, address feeRecipient) {
    //     depositFeeBps = depositFeeBps;
    //     withdrawalFeeBps = withdrawalFeeBps;
    //     feeRecipient = feeRecipient;
    // }

}
