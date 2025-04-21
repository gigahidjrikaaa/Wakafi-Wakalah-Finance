// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import Script for deployment capabilities and console for logging
import {Script, console} from "forge-std/Script.sol";
// Import your main WakalahPool contract
import {WakalahPool} from "../src/WakalahPool.sol";

/**
 * @title DeployWakalahPool
 * @notice Script to deploy the WakalahPool contract using Foundry.
 * Reads configuration (private key, owner, fee recipient) from environment variables.
 */
contract DeployWakalahPool is Script {

    /**
     * @notice Main deployment function executed by `forge script`.
     */
    function run() external {
        // --- 1. Load Deployment Configuration ---
        // It's crucial to load sensitive data like private keys from environment
        // variables rather than hardcoding them. Use a .env file locally.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address initialOwner = vm.envAddress("INITIAL_OWNER");
        address feeRecipient = vm.envAddress("FEE_RECIPIENT");

        // --- Basic Input Validation ---
        require(deployerPrivateKey != 0, "DeployScript: PRIVATE_KEY env variable not set or invalid.");
        require(initialOwner != address(0), "DeployScript: INITIAL_OWNER env variable not set or invalid.");
        require(feeRecipient != address(0), "DeployScript: FEE_RECIPIENT env variable not set or invalid.");

        // --- Log Deployment Info ---
        console.log("Starting WakalahPool deployment...");
        console.log("  Deployer Address (derived):", vm.addr(deployerPrivateKey));
        console.log("  Initial Owner (Ownable):", initialOwner);
        console.log("  Fee Recipient:", feeRecipient);
        console.log("  Network Chain ID:", block.chainid); // Log the target chain ID

        // --- 2. Start Broadcast ---
        // `vm.startBroadcast` tells Foundry to simulate or execute the following state changes
        // as actual transactions signed by the deployerPrivateKey.
        vm.startBroadcast(deployerPrivateKey);

        // --- 3. Deploy the WakalahPool Contract ---
        // Pass the required constructor arguments loaded from environment variables.
        WakalahPool wakalahPool = new WakalahPool(
            initialOwner, // The address that will initially own the contract (via Ownable)
            feeRecipient  // The address where collected fees will be sent
        );

        // --- 4. Stop Broadcast ---
        // Finalizes the transaction sequence.
        vm.stopBroadcast();

        // --- 5. Log Deployment Result ---
        console.log("----------------------------------");
        console.log("WakalahPool deployed successfully!");
        console.log("  Contract Address:", address(wakalahPool));
        console.log("----------------------------------");
    }
}
