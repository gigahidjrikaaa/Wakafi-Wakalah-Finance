// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Use a recent Solidity version

// Import necessary contracts from OpenZeppelin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // Or AccessControl for more roles
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol"; // Useful for tracking approved assets

contract WakalahPool is Ownable, ReentrancyGuard { // Inherit Ownable & ReentrancyGuard
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // --- State Variables ---

    // Mapping: User Address => Asset Address => Principal Amount Deposited
    mapping(address => mapping(address => uint256)) public userPrincipal;

    // Mapping: Asset Address => Total Principal Deposited for this asset
    mapping(address => uint256) public totalPrincipalByAsset;

    // Keep track of approved assets users can deposit (Managed by Owner/Admin)
    EnumerableSet.AddressSet private approvedAssets;

    // Fee structure (example: basis points, 100 = 1%)
    uint256 public depositFeeBps; // Fee on deposit
    uint256 public withdrawalFeeBps; // Fee on withdrawal
    // uint256 public managementFeeBps; // Periodic AUM fee - harder to implement safely on-chain without pull mechanism

    // Address where collected fees are sent
    address public feeRecipient;

    // --- Events ---
    event AssetApproved(address indexed asset, bool isApproved);
    event Deposit(address indexed user, address indexed asset, uint256 amount, uint256 feeAmount);
    event Withdrawal(address indexed user, address indexed asset, uint256 principalAmount, uint256 profitShareAmount, uint256 feeAmount);
    event FeesCollected(address indexed recipient, address indexed asset, uint256 amount);
    event ProfitRecorded(address indexed asset, uint256 profitAmount); // For simplified profit tracking

    // --- Modifiers ---
    modifier onlyApprovedAsset(address _asset) {
        require(approvedAssets.contains(_asset), "WakalahPool: Asset not approved");
        _;
    }

    // --- Constructor ---
    constructor(address _initialOwner, address _feeRecipient) Ownable(_initialOwner) {
        require(_feeRecipient != address(0), "WakalahPool: Invalid fee recipient");
        feeRecipient = _feeRecipient;
        // Initialize fees (example: 0.1% = 10 bps)
        depositFeeBps = 10;
        withdrawalFeeBps = 10;
    }

    // --- Admin Functions (Owner Controlled) ---

    function setApprovedAsset(address _asset, bool _isApproved) external onlyOwner {
        require(_asset != address(0), "WakalahPool: Invalid asset address");
        if (_isApproved) {
            approvedAssets.add(_asset);
        } else {
            // Consider implications: prevent new deposits, allow withdrawals?
            // For simplicity now, just remove. Add checks if needed.
            approvedAssets.remove(_asset);
        }
        emit AssetApproved(_asset, _isApproved);
    }

    function setFeeBps(uint256 _depositFeeBps, uint256 _withdrawalFeeBps) external onlyOwner {
        // Add sanity checks (e.g., fee not > 100% = 10000 bps)
        depositFeeBps = _depositFeeBps;
        withdrawalFeeBps = _withdrawalFeeBps;
        // Emit event
    }

    function setFeeRecipient(address _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "WakalahPool: Invalid fee recipient");
        feeRecipient = _newRecipient;
        // Emit event
    }

    // Function for simplified profit reporting (replace/enhance later)
    function recordProfit(address _asset, uint256 _profitAmount) external onlyOwner onlyApprovedAsset(_asset) {
        // In a real scenario, this might come from yield strategies
        // For now, just emit event. Logic for distribution needs careful design.
        // This function might just signal off-chain systems, or update some internal value metric.
        // Simplest model: Does nothing on-chain yet except event.
        emit ProfitRecorded(_asset, _profitAmount);
        // More complex: Update an internal "value per share" or similar metric.
    }

    // --- Core User Functions ---

    function deposit(address _asset, uint256 _amount) external nonReentrant onlyApprovedAsset(_asset) {
        require(_amount > 0, "WakalahPool: Deposit amount must be positive");

        uint256 feeAmount = (_amount * depositFeeBps) / 10000;
        uint256 netAmount = _amount - feeAmount; // Amount credited to user's principal

        require(netAmount > 0, "WakalahPool: Deposit amount too small after fee");

        // Update state BEFORE transfer
        userPrincipal[msg.sender][_asset] += netAmount;
        totalPrincipalByAsset[_asset] += netAmount;

        // Pull tokens from user (User must have approved contract first)
        IERC20(_asset).safeTransferFrom(msg.sender, address(this), _amount);

        // Send fee to recipient
        if (feeAmount > 0) {
            IERC20(_asset).safeTransfer(feeRecipient, feeAmount);
            emit FeesCollected(feeRecipient, _asset, feeAmount);
        }

        emit Deposit(msg.sender, _asset, netAmount, feeAmount);
    }

    function withdraw(address _asset, uint256 _principalAmountToWithdraw) external nonReentrant onlyApprovedAsset(_asset) {
        require(_principalAmountToWithdraw > 0, "WakalahPool: Withdraw amount must be positive");

        uint256 currentPrincipal = userPrincipal[msg.sender][_asset];
        require(currentPrincipal >= _principalAmountToWithdraw, "WakalahPool: Insufficient principal");

        // --- Profit Calculation (VERY SIMPLIFIED EXAMPLE) ---
        // This needs proper design based on how profit is tracked/allocated.
        // Example: Assume profit is proportional to principal share of total principal for that asset.
        // This is naive - doesn't account for time, etc. Needs a robust share-based system usually.
        // Let's assume for now: Withdraw principal + a *simulated/placeholder* profit share.
        // A real system needs a function like `calculateWithdrawableAmount(user, asset, principalAmount)`
        uint256 profitShareAmount = 0; // Placeholder - Needs real calculation logic!
        // --- End Simplified Profit Calculation ---

        uint256 totalWithdrawAmountBeforeFee = _principalAmountToWithdraw + profitShareAmount;
        uint256 feeAmount = (totalWithdrawAmountBeforeFee * withdrawalFeeBps) / 10000;
        uint256 netWithdrawAmount = totalWithdrawAmountBeforeFee - feeAmount;

        require(netWithdrawAmount > 0, "WakalahPool: Withdraw amount too small after fee");
        require(IERC20(_asset).balanceOf(address(this)) >= netWithdrawAmount, "WakalahPool: Insufficient pool balance"); // Crucial check!

        // Update state BEFORE transfer
        userPrincipal[msg.sender][_asset] -= _principalAmountToWithdraw;
        totalPrincipalByAsset[_asset] -= _principalAmountToWithdraw; // Note: Need to handle profit reduction too!

        // Transfer net amount to user
        IERC20(_asset).safeTransfer(msg.sender, netWithdrawAmount);

        // Send fee to recipient
        if (feeAmount > 0) {
            IERC20(_asset).safeTransfer(feeRecipient, feeAmount);
            emit FeesCollected(feeRecipient, _asset, feeAmount);
        }

        emit Withdrawal(msg.sender, _asset, _principalAmountToWithdraw, profitShareAmount, feeAmount);
    }


    // --- View Functions ---

    function isAssetApproved(address _asset) external view returns (bool) {
        return approvedAssets.contains(_asset);
    }

    function getApprovedAssets() external view returns (address[] memory) {
        return approvedAssets.values();
    }

    // Add more view functions as needed (e.g., calculate estimated profit share, view total pool value)
    function calculateEstimatedProfitShare(address _user, address _asset) external view returns (uint256) {
        // Placeholder: Needs real profit calculation logic
        uint256 userPrincipalAmount = userPrincipal[_user][_asset];
        uint256 totalPoolValue = totalPrincipalByAsset[_asset]; // Simplified
        // Example: Proportional share of total pool value
        return (userPrincipalAmount * totalPoolValue) / 100; // Placeholder logic
    }
    // --- Fallback Functions ---
    // Fallback function to prevent accidental ETH transfers
    // Reject any direct ETH transfers
    receive() external payable {
        revert("WakalahPool: Direct ETH deposits not accepted");
    }

    // Reject calls with no data
    fallback() external payable {
        revert("WakalahPool: Function does not exist");
    }

    // --- Internal Functions ---


}