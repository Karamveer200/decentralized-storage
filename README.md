# File Storage Smart Contracts - Testing Guide

This guide provides step-by-step instructions to compile, deploy, and test the File Storage smart contracts using Remix IDE. The testing is done in a simulated environment provided by Remix, without the need for external wallets or connecting to a real Ethereum network.

## Prerequisites

- Access to Remix IDE ([Remix IDE](https://remix.ethereum.org/))
- Basic understanding of Solidity smart contracts

## Steps to Test

### 1. Clone GitHub Repository

- Clone the GitHub repository containing the smart contracts into Remix IDE from the URL: [decentralized-storage](https://github.com/Karamveer200/decentralized-storage).
  - This step ensures that you have all the necessary smart contracts available in Remix for testing.
 
### 2. Compile and Deploy contracts

- In Remix file explorer, Go to `/contracts` folder.
- Compile all 4 contracts - `_UserManager`, `_NodeManager`, `_ChunkManager`, `_FileStorage`.
- Go to `Deploy & run transactions` tab and start deploying contract in following order - `_ChunkManager` -> `_UserManager` -> `_NodeManager` (need to pass _UserManager deployed contract address) -> `_FileManager` (need to pass deployed contract address of other 3 contracts).
- NOTE - You can copy any deployed contract address by clicking `copy` button under `Deployed/Unpinned Contracts` section in `Deploy & run transactions` tab.

### 3. Add Storage Nodes (storage providers)

To add storage nodes, follow these steps:

- Navigate to the deployed `_NodeManager` contract in Remix IDE.
- Locate the `addNode` function.
- Call the `addNode` function with `50 GWEI` (required for staking) using the following parameters:
  - `_nodeAddress`: Address of the storage node (example: `0xea5Db7668E91f989fA019Bd4ADEa347D65574aaA`). You can use any address obtained from [Vanity-ETH](https://vanity-eth.tk/).
  - `_initialStorage`: Initial storage capacity of the node (example: `1000000`). Specify the desired amount of storage capacity for the node.
- Click the "Transact" button to add the storage node.
- Now call `getNodeContractBalance` function to check the balance of NodeManager contract (it should be `50000000000`).

### 4. Register User (End users who will be storing files)

To register a user, follow these steps:

- Navigate to the deployed `_UserManager` contract in Remix IDE.
- Call the `registerUser` function with the following parameters:
  - `_userAddress`: Address of the user (example: `0x6d6AB9655Bb96997dEE8453431eb81639b528878`).

This register a new user with default "Free" tier with limites storage. So, let's upgrade to "Advanced" Tier.

- In same deployed `_UserManager` contract, call the `upgradeSubscription` funciton with `1 GWEI` value using the following parameters:
  - `_userAddress`: Upgrades to Advanced Tier. This address should be same as what you have used during `registerUser` function (example: `0x6d6AB9655Bb96997dEE8453431eb81639b528878`).
- Now call `getUserContractBalance` function to check the balance of UserManager contract (it should be `1000000000`).

### 5. Store Files

- Navigate to the deployed `_FileManager` contract in Remix IDE.
- Call the `storeFile` function with the following sample parameters to store a file:
  - `_fileName`: `Demo`
  - `_uniqueId`: `1010`
  - `_userAddress`: `0x6d6AB9655Bb96997dEE8453431eb81639b528878` (Note that _userAddress must be same as registered user in step 4)
  - `_fileSize`: `100`

### 6. Retrieve File Details

To retrieve details about a stored file, follow these steps:
- Navigate to the deployed `_FileManager` contract in Remix IDE.
- Call the `retrieveFile` function with the following sample parameters:
  - `_uniqueId`: `1010` (must be same as what you have used in `storeFile`)
  - `_userAddress`: `0x6d6AB9655Bb96997dEE8453431eb81639b528878` (must be same as what you have used in `storeFile`)
- Click on the transaction in Remix terminal and check the output. It should have your uploaded file details


### 7. Release payment to Storage Nodes (Can be configured in backend to get called bi-weekly)
Nodes are paid with the money that user (storage user) pays. You check the balance of `_UserManager` contract using `getUserContractBalance` fn in this user contract.
In order to release the payment from `UserContract` to the storage providers (Nodes), do the following - 
- Navigate to the deployed `_NodeManager` contract in Remix IDE.
- Call the `releaseNodePayments` fn and it will transfer the value from `_UserManager` to registered node addresses.
- You can call the `getUserContractBalance` fn of `_UserManager` again to verify. It should return `0`

### 8. Delete File
To delete a stored file, follow these steps:

- Navigate to the `_FileStorage.sol` contract in Remix IDE.
- Call the `deleteFile` function with the following sample parameters:
  - `_uniqueId`: `1010` (must be same as what you have used in `storeFile`)
  - `_userAddress`: `0x6d6AB9655Bb96997dEE8453431eb81639b528878` (must be same as what you have used in `storeFile`)
- Once the transaction is confirmed, the file will be permanently deleted from the storage system and you can check by trying to retrieve the file again which should result in file not found.

## Conclusion

You have now successfully compiled, deployed, and tested the File Storage smart contracts in Remix IDE.
