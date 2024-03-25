# File Storage Smart Contracts - Testing Guide

This guide provides step-by-step instructions to compile, deploy, and test the File Storage smart contracts using Remix IDE. The testing is done in a simulated environment provided by Remix, without the need for external wallets or connecting to a real Ethereum network.

## Prerequisites

- Access to Remix IDE ([Remix IDE](https://remix.ethereum.org/))
- Basic understanding of Solidity smart contracts

## Steps to Test

### 1. Clone GitHub Repository

- Clone the GitHub repository containing the smart contracts into Remix IDE from the URL: [decentralized-storage](https://github.com/Karamveer200/decentralized-storage).
  - This step ensures that you have all the necessary smart contracts available in Remix for testing.
 
### 2. Compile Contract

- Switch to the "Solidity compiler" tab in Remix.
- Open the "Advanced Configurations" drop down menu.
- Enable optimization as our contract is inheriting other contracts so that it does not throw warning of exceeding contract size.
- Click the "Compile _FileStorage.sol" button to compile the `_FileStorage` contract

### 3. Deploy Contract

- Switch to the "Deploy & Run Transactions" tab in Remix.
- Select the `_FileStorage.sol` contract from the dropdown menu.
- Click the "Deploy" button to deploy the `_FileStorage` contract.
- Also since `_FileStorage.sol` is inheriting other contracts, please enable 

### 4. Add Storage Nodes

To add storage nodes, follow these steps:

- Navigate to the deployed contract in Remix IDE.
- Locate the `addNode` function.
- Call the `addNode` function with the following parameters:
  - `_nodeAddress`: Address of the storage node (example: 0xea5Db7668E91f989fA019Bd4ADEa347D65574aaA). You can use any address obtained from [Vanity-ETH](https://vanity-eth.tk/).
  - `_initialStorage`: Initial storage capacity of the node (example: 1000000). Specify the desired amount of storage capacity for the node.
- Specify the staking amount of 50 GWEI in the "value" field.
- Click the "Transact" button to add the storage node.

### 5. Register User

To register yourself as a user, follow these steps:

- Navigate to the deployed contract in Remix IDE.
- Locate the `registerUser` function.
- Call the `registerUser` function.
- This step ensures that the user is registered within the system before upgrading their subscription.

### 6. Upgrade Subscription to Advanced Tier

To upgrade your subscription tier to the Advanced Tier, follow these steps:

- Ensure that you have sufficient funds in your Ethereum account to cover the subscription upgrade fee.
- Navigate to the deployed contract in Remix IDE.
- Locate the `upgradeSubscription` function.
- Enter `1` in the `newTier` parameter box.
- Specify the staking amount of 1 GWEI in the "value" field.
- Click the "Transact" button to upgrade your subscription to Advanced.

### 7. Store Files

- Navigate to the `_FileStorage.sol` contract in the "Deploy & Run Transactions" tab.
- Call the `storeFile` function with the following sample parameters to store a file:
  - `_chunksSizeArr`: [100,100]
  - `_fileName`: "example.txt"
  - `_fileType`: "text"
  - `_fileEncoding`: "7bit"
  - `_uniqueId`: "123456789"
  - `_fileSize`: 1000
  - `_fileHash`: "0x123abc"
  - `_chunkHashes`: ["chunk","Hash"]
- Explore other functionalities and test edge cases as needed.
- Use Remix's debugging tools to trace transactions and inspect contract states for thorough testing.

### 8. Retrieve File Details

To retrieve details about a stored file, follow these steps:

- Navigate to the `_FileStorage.sol` contract in Remix IDE.
- Locate the `retrieveFileDetails` function.
- Call the `retrieveFileDetails` function with the specified parameters.
- Review the returned details, including file metadata and chunk information.

### 9. Delete File

To delete a stored file, follow these steps:

- Navigate to the `_FileStorage.sol` contract in Remix IDE.
- Locate the `deleteFile` function.
- Call the `deleteFile` function with the specified parameter.
- Once the transaction is confirmed, the file will be permanently deleted from the storage system and you can check by trying to retrieve the file again which should result in file not found.

## Conclusion

You have now successfully compiled, deployed, and tested the File Storage smart contracts in Remix IDE.
