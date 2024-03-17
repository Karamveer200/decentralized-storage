# File Storage Smart Contracts - Testing Guide

This guide provides step-by-step instructions to compile, deploy, and test the File Storage smart contracts using Remix IDE. The testing is done in a simulated environment provided by Remix, without the need for external wallets or connecting to a real Ethereum network.

## Prerequisites

- Access to Remix IDE ([Remix IDE](https://remix.ethereum.org/))
- Basic understanding of Solidity smart contracts

## Steps to Test

### 1. Clone GitHub Repository

- Clone the GitHub repository containing the smart contracts into Remix IDE from the URL: [decentralized-storage](https://github.com/Karamveer200/decentralized-storage).
  - This step ensures that you have all the necessary smart contracts available in Remix for testing.

### 2. Deploy Contract with Gwei

- Switch to the "Deploy & Run Transactions" tab in Remix.
- Select the `_FileStorage.sol` contract from the dropdown menu.
- Specify an address from which the contract will be deployed. You can use an address like `0x55Cc5bF403e420057c457740F8838084C5DC3490` or other addresses from [Vanity-ETH](https://vanity-eth.tk/).
- Add an amount of 100 GWEI in the "value" field to deploy the contract. This ensures that the contract is deployed with sufficient funds for executing payable functions.
- Click the "Deploy" button to deploy the `_FileStorage` contract.

### 3. Add Storage Nodes

To add storage nodes, follow these steps:

- Navigate to the deployed contract in Remix IDE.
- Locate the `addNode` function.
- Call the `addNode` function with the following parameters:
  - `_nodeAddress`: Address of the storage node. You can use any address obtained from [Vanity-ETH](https://vanity-eth.tk/).
  - `_initialStorage`: Initial storage capacity of the node. Specify the desired amount of storage capacity for the node.
- Ensure that the node contains sufficient funds (Gwei or other currency) to cover the staking amount required by the `addNode` function.
- This will add the storage node.
  
  **Note:** You can add multiple storage nodes by deploying the contract with different addresses obtained from services like Vanity-ETH. Each node requires a separate deployment and staking amount.

### 4. Upgrade Subscription to Advanced Tier

To upgrade your subscription tier to the Advanced Tier, follow these steps:

- Ensure that you have sufficient funds in your Ethereum account to cover the subscription upgrade fee.
- Navigate to the deployed contract in Remix IDE.
- Locate the `upgradeSubscription` function.
- Call the `upgradeSubscription` function with the following parameter:
  - `newTier`: Set the value to 1 to upgrade to the Advanced Tier.
- Once the transaction is confirmed, your subscription tier will be upgraded to Advanced.

### 5. Store Files

- Navigate to the `_FileStorage.sol` contract in the "Deploy & Run Transactions" tab.
- Call the `storeFile` function with the following sample parameters to store a file:
  - `_chunksSizeArr`: [100]
  - `_fileName`: "example.txt"
  - `_fileType`: "text"
  - `_fileEncoding`: "7bit"
  - `_uniqueId`: "123456789"
  - `_fileSize`: 1000
  - `_fileHash`: "0x123abc"
  - `_chunkHashes`: ["chunkHash"]
- Explore other functionalities and test edge cases as needed.
- Use Remix's debugging tools to trace transactions and inspect contract states for thorough testing.

### 6. Retrieve File Details

To retrieve details about a stored file, follow these steps:

- Navigate to the `_FileStorage.sol` contract in Remix IDE.
- Locate the `retrieveFileDetails` function.
- Call the `retrieveFileDetails` function with the following parameter:
  - `_fileId`: Specify the unique identifier of the file you want to retrieve details for.
- Review the returned details, including file metadata and chunk information.

### 7. Delete File

To delete a stored file, follow these steps:

- Navigate to the `_FileStorage.sol` contract in Remix IDE.
- Locate the `deleteFile` function.
- Call the `deleteFile` function with the following parameter:
  - `_fileId`: Specify the unique identifier of the file you want to delete.
- Once the transaction is confirmed, the file will be permanently deleted from the storage system.

## Conclusion

You have now successfully compiled, deployed, and tested the File Storage smart contracts in Remix IDE. Make sure to explore all functionalities and thoroughly test the contracts to ensure they meet your requirements.
