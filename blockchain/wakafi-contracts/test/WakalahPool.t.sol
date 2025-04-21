// SPDX-License-Identifier: MIT

// Example test structure (in test/WakalahPool.t.sol)
import "forge-std/Test.sol";
import "../src/WakalahPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; // Or use a mock ERC20

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MCK") {}
    function mint(address to, uint256 amount) external { _mint(to, amount); }
}

contract WakalahPoolTest is Test {
    WakalahPool pool;
    MockERC20 token;
    address owner = address(0x1); // Test owner
    address user = address(0x2);  // Test user
    address feeRecipient = address(0x3);

    function setUp() public {
        vm.startPrank(owner); // Act as owner
        token = new MockERC20();
        pool = new WakalahPool(owner, feeRecipient);
        pool.setApprovedAsset(address(token), true);
        vm.stopPrank();

        // Give user some tokens
        token.mint(user, 1_000_000e18);
    }

    function testDeposit() public {
        uint256 depositAmount = 100_000e18;
        uint256 feeAmount = (depositAmount * pool.depositFeeBps()) / 10000;
        uint256 netAmount = depositAmount - feeAmount;

        vm.startPrank(user);
        // User approves the pool contract to spend their tokens
        token.approve(address(pool), depositAmount);

        // Expect the Deposit event
        vm.expectEmit(true, true, true, true);
        emit WakalahPool.Deposit(user, address(token), netAmount, feeAmount);

        // Perform deposit
        pool.deposit(address(token), depositAmount);
        vm.stopPrank();

        // Assert state changes
        assertEq(pool.userPrincipal(user, address(token)), netAmount, "User principal mismatch");
        assertEq(pool.totalPrincipalByAsset(address(token)), netAmount, "Total principal mismatch");
        assertEq(token.balanceOf(address(pool)), netAmount, "Pool token balance mismatch"); // Check pool balance after fee
        assertEq(token.balanceOf(feeRecipient), feeAmount, "Fee recipient balance mismatch");
    }

    // Add tests for withdrawal, fees, admin functions, edge cases, reentrancy etc.
}