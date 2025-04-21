# Wakafi (Wakalah Finance) - Blockchain Contracts

**Date:** April 21, 2025
**Version:** 1.0

## Overview

This directory contains the Solidity smart contracts for the Wakafi platform, developed using the [Foundry](https://book.getfoundry.sh/) framework. The core of this project is the `WakalahPool.sol` contract, which implements a Sharia-compliant yield generation mechanism based on the Islamic finance principle of **Wakalah bil Istithmar (Agency for Investment)**.

Instead of traditional interest (Riba), users deposit approved Halal assets, appointing the protocol as their agent (Wakil). The protocol (conceptually) manages these assets in compliant strategies, and users receive profit share minus a service fee (Ujrah).

This README provides guidance for Backend (BE) and Frontend (FE) developers on understanding, building, testing, deploying, and interacting with these contracts.

## Core Contracts

* **`src/WakalahPool.sol`**: The main contract implementing the Wakalah pool logic.
    * Handles deposits and withdrawals of approved ERC20 assets.
    * Tracks user principal balances.
    * Calculates and collects Ujrah (fees) based on configurable rates.
    * Includes basic administrative functions (managed by an `owner`).
    * Emits events for key actions (Deposit, Withdrawal, FeesCollected, etc.) for off-chain tracking.
    * **Note:** Profit calculation/distribution logic is currently simplified and requires further development based on the chosen yield strategies.

## Key Concepts for BE/FE Interaction

* **Owner (`Ownable`)**: The contract has an owner (set during deployment) who can call administrative functions (e.g., approve assets, set fees). This is managed on-chain. See `owner()` view function.
* **Fee Recipient**: An address (set during deployment) where collected Ujrah fees are sent. See `feeRecipient()` view function.
* **Approved Assets**: Only specific ERC20 tokens vetted for Sharia compliance can be deposited. This list is managed by the contract owner via `setApprovedAsset` and can be queried using `getApprovedAssets()` or `isAssetApproved(address)`. The BE/FE should use this list to validate user inputs.
* **Ujrah (Fees)**: Service fees charged on deposits and/or withdrawals, configured in basis points (bps). See `depositFeeBps()` and `withdrawalFeeBps()` view functions. Fees are automatically transferred to the `feeRecipient`.
* **Events**: The contract emits events for significant actions. The Backend should listen to these events to update its off-chain database cache (e.g., transaction history, user balances).

## Setup & Installation

1.  **Install Foundry:** Follow the instructions at [https://book.getfoundry.sh/getting-started/installation](https://book.getfoundry.sh/getting-started/installation).
    ```bash
    foundryup
    ```
2.  **Install Dependencies:** Navigate to this directory (`blockchain/wakafi-contracts` or similar) in your terminal and run:
    ```bash
    forge install
    ```
    This will download dependencies like OpenZeppelin contracts into the `lib/` folder based on `foundry.toml` remappings.

## Compilation

To compile the smart contracts:

```bash
forge build
```

- Output: Compiled artifacts, including the crucial ABI (Application Binary Interface) JSON files, will be placed in the out/ directory (e.g., out/WakalahPool.sol/WakalahPool.json).
- ABI for BE/FE: Backend and Frontend developers will need the ABI from WakalahPool.json to know how to encode function calls and decode results/events when interacting with the deployed contract.

## Testing
To run the Solidity test suite located in the test/ directory:
```bash
# Run all tests with detailed output (recommended)
forge test -vvv
```
This command compiles the contracts and tests, then executes all functions starting with test in files ending with .t.sol.

## Deployment
Deployment is handled via Foundry scripts located in the script/ directory.

## Interacting with Contracts
- BE/FE Integration: Use the deployed contract address and the ABI (from out/WakalahPool.sol/WakalahPool.json) with Web3 libraries like Ethers.js or Viem to interact with the contract (read state, call functions, listen to events).
- Command Line (Optional): Foundry's cast tool can be used for direct command-line interaction (e.g., cast call, cast send). See cast --help.

## Network Information
Target Network: Pharos Devnet
Chain ID: 50002 (Based on previous logs)
Explorer: https://pharosscan.xyz