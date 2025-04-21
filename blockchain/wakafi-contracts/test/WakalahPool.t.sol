// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Foundry's testing utilities and standard libraries
import {Test, console} from "forge-std/Test.sol";
// Import the contract to be tested
import {WakalahPool} from "../src/WakalahPool.sol";
// Import OpenZeppelin contracts needed for testing (or use mocks)
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // Using OZ implementation for mock
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; // To test reverts

// --- Mock ERC20 Token for Testing ---
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/**
 * @title WakalahPoolTest
 * @notice Test suite for the WakalahPool contract using Foundry.
 */
contract WakalahPoolTest is Test {
    // --- Test Setup ---

    WakalahPool internal pool;
    MockERC20 internal usdc; // Mock USDC
    MockERC20 internal dai; // Mock DAI (another approved asset)
    MockERC20 internal unapprovedToken; // A token NOT approved

    // Define addresses for actors in the tests
    address internal constant OWNER = address(0x100); // Test owner address
    address internal constant USER_ALICE = address(0x200); // Test user 1
    address internal constant USER_BOB = address(0x300); // Test user 2
    address internal constant FEE_RECIPIENT = address(0x400); // Test fee recipient
    address internal constant RANDOM_ADDRESS = address(0x500);

    // Constants for fees (matching constructor defaults)
    uint256 internal constant INITIAL_DEPOSIT_FEE_BPS = 10; // 0.1%
    uint256 internal constant INITIAL_WITHDRAWAL_FEE_BPS = 10; // 0.1%

    // Initial funding amount for users
    uint256 internal constant INITIAL_USER_FUNDS = 1_000_000 * 1e6; // Assuming 6 decimals for USDC

    /**
     * @notice Sets up the testing environment before each test function runs.
     */
    function setUp() public virtual {
        // Deploy mock tokens
        usdc = new MockERC20("Mock USDC", "mUSDC"); // 6 decimals usually
        dai = new MockERC20("Mock DAI", "mDAI"); // 18 decimals usually
        unapprovedToken = new MockERC20("Unapproved Token", "NOPE");

        // Deploy the WakalahPool contract, acting as the OWNER
        vm.startPrank(OWNER);
        pool = new WakalahPool(OWNER, FEE_RECIPIENT);
        // Pre-approve USDC and DAI for testing
        pool.setApprovedAsset(address(usdc), true);
        pool.setApprovedAsset(address(dai), true);
        vm.stopPrank();

        // Mint initial funds for users
        usdc.mint(USER_ALICE, INITIAL_USER_FUNDS);
        dai.mint(USER_ALICE, INITIAL_USER_FUNDS * 1e12); // Adjust for 18 decimals
        usdc.mint(USER_BOB, INITIAL_USER_FUNDS);
    }

    // --- Constructor & Initial State Tests ---

    function test_InitialState() public {
        assertEq(pool.owner(), OWNER, "Incorrect owner");
        assertEq(pool.feeRecipient(), FEE_RECIPIENT, "Incorrect fee recipient");
        assertEq(pool.depositFeeBps(), INITIAL_DEPOSIT_FEE_BPS, "Incorrect initial deposit fee");
        assertEq(pool.withdrawalFeeBps(), INITIAL_WITHDRAWAL_FEE_BPS, "Incorrect initial withdrawal fee");
        assertTrue(pool.isAssetApproved(address(usdc)), "USDC should be approved");
        assertTrue(pool.isAssetApproved(address(dai)), "DAI should be approved");
        assertFalse(pool.isAssetApproved(address(unapprovedToken)), "Unapproved token should not be approved");
        assertEq(pool.getApprovedAssetsCount(), 2, "Incorrect initial approved asset count");
    }

    // --- Admin Function Tests ---

    function test_SetApprovedAsset_AddAndRemove() public {
        vm.startPrank(OWNER);
        // Add unapproved token
        vm.expectEmit(true, false, false, true); // Check indexed asset, not bool
        emit WakalahPool.AssetApproved(address(unapprovedToken), true);
        pool.setApprovedAsset(address(unapprovedToken), true);
        assertTrue(pool.isAssetApproved(address(unapprovedToken)), "Should be approved after adding");
        assertEq(pool.getApprovedAssetsCount(), 3, "Count should be 3 after adding");

        // Remove it
        vm.expectEmit(true, false, false, true);
        emit WakalahPool.AssetApproved(address(unapprovedToken), false);
        pool.setApprovedAsset(address(unapprovedToken), false);
        assertFalse(pool.isAssetApproved(address(unapprovedToken)), "Should not be approved after removing");
        assertEq(pool.getApprovedAssetsCount(), 2, "Count should be 2 after removing");
        vm.stopPrank();
    }

    function test_Fail_SetApprovedAsset_NotOwner() public {
        vm.startPrank(USER_ALICE); // Act as non-owner
        vm.expectRevert(Ownable.OwnableUnauthorizedAccount.selector); // Expect revert from Ownable
        pool.setApprovedAsset(address(unapprovedToken), true);
        vm.stopPrank();
    }

     function test_Fail_SetApprovedAsset_ZeroAddress() public {
        vm.startPrank(OWNER);
        vm.expectRevert("WakalahPool: Invalid asset address");
        pool.setApprovedAsset(address(0), true);
        vm.stopPrank();
    }

    function test_SetFeeBps() public {
        uint256 newDepositFee = 50; // 0.5%
        uint256 newWithdrawalFee = 75; // 0.75%
        vm.startPrank(OWNER);
        vm.expectEmit(true, true, false, false); // Check both fees, not indexed
        emit WakalahPool.FeeBpsUpdated(newDepositFee, newWithdrawalFee);
        pool.setFeeBps(newDepositFee, newWithdrawalFee);
        assertEq(pool.depositFeeBps(), newDepositFee, "Deposit fee mismatch");
        assertEq(pool.withdrawalFeeBps(), newWithdrawalFee, "Withdrawal fee mismatch");
        vm.stopPrank();
    }

    function test_Fail_SetFeeBps_NotOwner() public {
         vm.startPrank(USER_ALICE);
         vm.expectRevert(Ownable.OwnableUnauthorizedAccount.selector);
         pool.setFeeBps(50, 75);
         vm.stopPrank();
    }

    function test_Fail_SetFeeBps_TooHigh() public {
        vm.startPrank(OWNER);
        vm.expectRevert("WakalahPool: Deposit fee cannot exceed 100%");
        pool.setFeeBps(10001, 10); // > 10000 bps
        vm.expectRevert("WakalahPool: Withdrawal fee cannot exceed 100%");
        pool.setFeeBps(10, 10001); // > 10000 bps
        vm.stopPrank();
    }

    function test_SetFeeRecipient() public {
        vm.startPrank(OWNER);
        vm.expectEmit(true, false, false, true); // Check indexed recipient
        emit WakalahPool.FeeRecipientUpdated(RANDOM_ADDRESS);
        pool.setFeeRecipient(RANDOM_ADDRESS);
        assertEq(pool.feeRecipient(), RANDOM_ADDRESS, "Fee recipient mismatch");
        vm.stopPrank();
    }

     function test_Fail_SetFeeRecipient_NotOwner() public {
        vm.startPrank(USER_ALICE);
        vm.expectRevert(Ownable.OwnableUnauthorizedAccount.selector);
        pool.setFeeRecipient(RANDOM_ADDRESS);
        vm.stopPrank();
    }

    function test_Fail_SetFeeRecipient_ZeroAddress() public {
        vm.startPrank(OWNER);
        vm.expectRevert("WakalahPool: Invalid fee recipient");
        pool.setFeeRecipient(address(0));
        vm.stopPrank();
    }

    function test_RecordProfit() public {
        uint256 profitAmount = 5000 * 1e6; // Example profit
        vm.startPrank(OWNER);
        vm.expectEmit(true, false, false, true); // Check indexed asset
        emit WakalahPool.ProfitRecorded(address(usdc), profitAmount);
        pool.recordProfit(address(usdc), profitAmount);
        // Note: Add assertions here if recordProfit updates internal state later
        vm.stopPrank();
    }

    function test_Fail_RecordProfit_NotOwner() public {
        vm.startPrank(USER_ALICE);
        vm.expectRevert(Ownable.OwnableUnauthorizedAccount.selector);
        pool.recordProfit(address(usdc), 100);
        vm.stopPrank();
    }

     function test_Fail_RecordProfit_NotApprovedAsset() public {
        vm.startPrank(OWNER);
        vm.expectRevert("WakalahPool: Asset not approved");
        pool.recordProfit(address(unapprovedToken), 100);
        vm.stopPrank();
    }


    // --- Deposit Function Tests ---

    function test_Deposit_Success() public {
        uint256 depositAmount = 100_000 * 1e6; // 100k USDC
        uint256 feeBps = pool.depositFeeBps();
        uint256 expectedFee = (depositAmount * feeBps) / 10000;
        uint256 expectedNetAmount = depositAmount - expectedFee;

        // Alice deposits USDC
        vm.startPrank(USER_ALICE);
        // 1. Approve the pool contract to spend Alice's USDC
        usdc.approve(address(pool), depositAmount);

        // 2. Check balances before deposit
        uint256 aliceBalanceBefore = usdc.balanceOf(USER_ALICE);
        uint256 poolBalanceBefore = usdc.balanceOf(address(pool));
        uint256 feeRecipientBalanceBefore = usdc.balanceOf(FEE_RECIPIENT);

        // 3. Expect events
        vm.expectEmit(true, true, true, true); // Check all indexed params
        emit WakalahPool.Deposit(USER_ALICE, address(usdc), expectedNetAmount, expectedFee);
        if (expectedFee > 0) {
             vm.expectEmit(true, true, true, true);
             emit WakalahPool.FeesCollected(FEE_RECIPIENT, address(usdc), expectedFee);
        }

        // 4. Perform deposit
        pool.deposit(address(usdc), depositAmount);
        vm.stopPrank();

        // 5. Assert state changes and balances
        assertEq(pool.userPrincipal(USER_ALICE, address(usdc)), expectedNetAmount, "Alice principal mismatch");
        assertEq(pool.totalPrincipalByAsset(address(usdc)), expectedNetAmount, "Total USDC principal mismatch");
        assertEq(usdc.balanceOf(USER_ALICE), aliceBalanceBefore - depositAmount, "Alice balance incorrect");
        // Pool balance should increase by net amount (gross deposit - fee)
        assertEq(usdc.balanceOf(address(pool)), poolBalanceBefore + expectedNetAmount, "Pool balance incorrect");
        assertEq(usdc.balanceOf(FEE_RECIPIENT), feeRecipientBalanceBefore + expectedFee, "Fee recipient balance incorrect");
    }

    function test_Fail_Deposit_NotApprovedAsset() public {
        vm.startPrank(USER_ALICE);
        unapprovedToken.approve(address(pool), 100e18);
        vm.expectRevert("WakalahPool: Asset not approved");
        pool.deposit(address(unapprovedToken), 100e18);
        vm.stopPrank();
    }

    function test_Fail_Deposit_InsufficientAllowance() public {
        uint256 depositAmount = 100_000 * 1e6;
        vm.startPrank(USER_ALICE);
        // Approve less than deposit amount
        usdc.approve(address(pool), depositAmount - 1);
        // ERC20: transfer amount exceeds allowance
        vm.expectRevert(); // OZ SafeERC20 reverts without specific message here
        pool.deposit(address(usdc), depositAmount);
        vm.stopPrank();
    }

    function test_Fail_Deposit_InsufficientBalance() public {
         uint256 depositAmount = INITIAL_USER_FUNDS + 1; // More than Alice has
         vm.startPrank(USER_ALICE);
         usdc.approve(address(pool), depositAmount);
         // ERC20: transfer amount exceeds balance
         vm.expectRevert(); // OZ SafeERC20 reverts without specific message here
         pool.deposit(address(usdc), depositAmount);
         vm.stopPrank();
    }

     function test_Fail_Deposit_ZeroAmount() public {
        vm.startPrank(USER_ALICE);
        vm.expectRevert("WakalahPool: Deposit amount must be positive");
        pool.deposit(address(usdc), 0);
        vm.stopPrank();
    }

    function test_Fail_Deposit_AmountTooSmallAfterFee() public {
         // Set high fee temporarily
         vm.startPrank(OWNER);
         pool.setFeeBps(10000, 10); // 100% deposit fee
         vm.stopPrank();

         uint256 depositAmount = 10 * 1e6;
         vm.startPrank(USER_ALICE);
         usdc.approve(address(pool), depositAmount);
         vm.expectRevert("WakalahPool: Deposit amount too small after fee");
         pool.deposit(address(usdc), depositAmount); // Fee = amount, netAmount = 0
         vm.stopPrank();
    }

    // --- Withdraw Function Tests (Simplified Profit) ---

    function test_Withdraw_Success_FullAmount() public {
        // 1. Alice deposits first
        uint256 depositAmount = 100_000 * 1e6;
        uint256 depositFeeBps = pool.depositFeeBps();
        uint256 depositFee = (depositAmount * depositFeeBps) / 10000;
        uint256 netDepositAmount = depositAmount - depositFee;

        vm.startPrank(USER_ALICE);
        usdc.approve(address(pool), depositAmount);
        pool.deposit(address(usdc), depositAmount);
        vm.stopPrank();

        // 2. Alice withdraws her full principal (assuming 0 profit for now)
        uint256 principalToWithdraw = netDepositAmount;
        // Placeholder: Assuming _calculateProfitShare returns 0
        uint256 expectedProfitShare = 0;
        uint256 totalWithdrawBeforeFee = principalToWithdraw + expectedProfitShare;
        uint256 withdrawalFeeBps = pool.withdrawalFeeBps();
        uint256 expectedWithdrawalFee = (totalWithdrawBeforeFee * withdrawalFeeBps) / 10000;
        uint256 expectedNetWithdrawal = totalWithdrawBeforeFee - expectedWithdrawalFee;

        vm.startPrank(USER_ALICE);
        // Check balances before withdrawal
        uint256 aliceBalanceBefore = usdc.balanceOf(USER_ALICE);
        uint256 poolBalanceBefore = usdc.balanceOf(address(pool));
        uint256 feeRecipientBalanceBefore = usdc.balanceOf(FEE_RECIPIENT);

        // Expect events
        vm.expectEmit(true, true, true, true);
        emit WakalahPool.Withdrawal(USER_ALICE, address(usdc), principalToWithdraw, expectedProfitShare, expectedWithdrawalFee);
        if (expectedWithdrawalFee > 0) {
            vm.expectEmit(true, true, true, true);
            emit WakalahPool.FeesCollected(FEE_RECIPIENT, address(usdc), expectedWithdrawalFee);
        }

        // Perform withdrawal
        pool.withdraw(address(usdc), principalToWithdraw);
        vm.stopPrank();

        // Assert state changes and balances
        assertEq(pool.userPrincipal(USER_ALICE, address(usdc)), 0, "Alice principal should be 0");
        // Assuming only Alice deposited
        assertEq(pool.totalPrincipalByAsset(address(usdc)), 0, "Total principal should be 0");
        assertEq(usdc.balanceOf(USER_ALICE), aliceBalanceBefore + expectedNetWithdrawal, "Alice balance incorrect after withdraw");
        assertEq(usdc.balanceOf(address(pool)), poolBalanceBefore - expectedNetWithdrawal, "Pool balance incorrect after withdraw");
        assertEq(usdc.balanceOf(FEE_RECIPIENT), feeRecipientBalanceBefore + expectedWithdrawalFee, "Fee recipient balance incorrect after withdraw");
    }

     function test_Withdraw_Success_PartialAmount() public {
        // 1. Deposit
        uint256 depositAmount = 100_000 * 1e6;
        uint256 depositFee = (depositAmount * pool.depositFeeBps()) / 10000;
        uint256 netDepositAmount = depositAmount - depositFee;
        vm.startPrank(USER_ALICE);
        usdc.approve(address(pool), depositAmount);
        pool.deposit(address(usdc), depositAmount);
        vm.stopPrank();

        // 2. Withdraw partially
        uint256 principalToWithdraw = netDepositAmount / 2; // Withdraw half
        uint256 expectedProfitShare = 0; // Placeholder
        uint256 totalWithdrawBeforeFee = principalToWithdraw + expectedProfitShare;
        uint256 expectedWithdrawalFee = (totalWithdrawBeforeFee * pool.withdrawalFeeBps()) / 10000;
        uint256 expectedNetWithdrawal = totalWithdrawBeforeFee - expectedWithdrawalFee;
        uint256 remainingPrincipal = netDepositAmount - principalToWithdraw;

        vm.startPrank(USER_ALICE);
        uint256 aliceBalanceBefore = usdc.balanceOf(USER_ALICE);
        uint256 poolBalanceBefore = usdc.balanceOf(address(pool));

        // Perform withdrawal
        pool.withdraw(address(usdc), principalToWithdraw);
        vm.stopPrank();

        // Assert state changes
        assertEq(pool.userPrincipal(USER_ALICE, address(usdc)), remainingPrincipal, "Alice remaining principal mismatch");
        assertEq(pool.totalPrincipalByAsset(address(usdc)), remainingPrincipal, "Total remaining principal mismatch"); // Assumes only Alice
        assertEq(usdc.balanceOf(USER_ALICE), aliceBalanceBefore + expectedNetWithdrawal, "Alice balance incorrect after partial withdraw");
        assertEq(usdc.balanceOf(address(pool)), poolBalanceBefore - expectedNetWithdrawal, "Pool balance incorrect after partial withdraw");
    }

    function test_Fail_Withdraw_InsufficientPrincipal() public {
        // 1. Deposit small amount
        uint256 depositAmount = 10 * 1e6;
        uint256 depositFee = (depositAmount * pool.depositFeeBps()) / 10000;
        uint256 netDepositAmount = depositAmount - depositFee;
        vm.startPrank(USER_ALICE);
        usdc.approve(address(pool), depositAmount);
        pool.deposit(address(usdc), depositAmount);
        vm.stopPrank();

        // 2. Try to withdraw more than deposited principal
        uint256 principalToWithdraw = netDepositAmount + 1;
        vm.startPrank(USER_ALICE);
        vm.expectRevert("WakalahPool: Insufficient principal");
        pool.withdraw(address(usdc), principalToWithdraw);
        vm.stopPrank();
    }

     function test_Fail_Withdraw_ZeroAmount() public {
         // Deposit first
        vm.startPrank(USER_ALICE);
        usdc.approve(address(pool), 100e6);
        pool.deposit(address(usdc), 100e6);
        vm.stopPrank();

        // Try withdraw 0
        vm.startPrank(USER_ALICE);
        vm.expectRevert("WakalahPool: Withdraw amount must be positive");
        pool.withdraw(address(usdc), 0);
        vm.stopPrank();
     }

     function test_Fail_Withdraw_NotApprovedAsset() public {
        vm.startPrank(USER_ALICE);
        vm.expectRevert("WakalahPool: Asset not approved");
        pool.withdraw(address(unapprovedToken), 100);
        vm.stopPrank();
     }

     // --- TODO: Add More Tests ---
     // - Test withdrawal when profit calculation is implemented
     // - Test interactions between multiple users and multiple assets
     // - Test reentrancy guards more thoroughly with a mock attacker contract
     // - Test edge cases for fee calculations (very small/large amounts)
     // - Test pausing/emergency functions if added
     // - Test invariant conditions if applicable (e.g., totalPrincipal always <= sum of userPrincipals)

}
