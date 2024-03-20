# Decentralized File Storage System Design Report

## Overview

The decentralized file storage system leverages blockchain technology to offer a secure, transparent, and decentralized solution for storing and managing files. By utilizing the Ethereum blockchain, the system ensures data integrity, security, and access control while providing a distributed framework that eliminates single points of failure. The core functionality revolves around enabling users to upload, store, retrieve, and manage their files across a network of decentralized nodes while also providing incentives to the nodes to provide storage. Blockchain plays a pivotal role in achieving decentralization by storing metadata about files and transactions, handling node management, and ensuring secure and transparent interactions between users and storage nodes.

## Smart Contracts

The system is powered by four inter-operable smart contracts deployed on the Ethereum blockchain, each designed to handle specific aspects of the file storage process. These contracts work together to facilitate the secure and efficient storage and retrieval of files in a decentralized manner. Below is a description of each contract and its key functions:

### 1. **FileStorageManager.sol**
- **Purpose**: Serves as the central contract that integrates file storage, node management, user management, and chunk management functionalities. It handles file uploads, metadata storage, file retrieval, and deletion processes.
- **Functions**:
  - `storeFile`: Distributes file chunks to nodes, stores file metadata, and manages storage limits based on user tier.
  - `storeFileMetadata`: Stores metadata for uploaded files, including file name, type, hash, size, upload time, and owner.
  - `retrieveFilesArray`: Returns an array of file metadata for the requesting user.
  - `retrieveFileDetails`: Retrieves file metadata and chunk node addresses for a specified file ID.
  - `deleteFile`: Removes file metadata and chunks from storage nodes and the blockchain.
  - `releasePayments`: Handles payment distribution to nodes for storing and retrieving file chunks.

### 2. **ChunkManager.sol**
- **Purpose**: Manages the chunk-related functionalities, including file hash storage, validation of file authenticity, and duplication settings for file chunks.
- **Functions**:
  - `getFileHash`: Retrieves the hash of a stored file using its ID.
  - `storeFileHash`: Stores the hash of a file associated with its ID.
  - `deleteFileHash`: Deletes the hash entry for a specified file ID.
  - `validateFileAuthenticity`: Validates the authenticity of a file by comparing its hash with the stored hash.
  - `areStringsEqual`: Utility function to compare two strings for equality.

### 3. **NodeManager.sol**
- **Purpose**: Handles the registration, management, and interaction with storage nodes within the network. It manages node storage capacity, chunk storage, and node payments.
- **Functions**:
  - `addNode`: Registers a new storage node with its initial storage capacity.
  - `updateAvailableStorage`: Updates the available storage for a node.
  - `storeChunkInNode`: Stores a file chunk in a specified node.
  - `retrieveChunkNodeAddresses`: Retrieves addresses of nodes storing chunks of a specific file.
  - `deleteChunkInNode`: Deletes chunk data for a given file from all nodes.
  - `findAvailableNode`: Finds an available node with sufficient storage capacity for a new chunk.
  - `returnInitialStake`: Returns the initial stake to a node owner.
  - `flagAsBadActor`: Flags a node as a bad actor based on its behavior.

### 4. **UserManager.sol**
- **Purpose**: Manages user registration, subscription tiers, and storage allocations. It also handles payments from users for storage services.
- **Functions**:
  - `registerUser`: Registers a new user with a default free tier subscription.
  - `upgradeSubscription`: Allows users to upgrade their subscription tier.
  - `addStorage`: Adds additional storage for PayAsYouGo users based on their payments.
  - `getUser`: Retrieves user information, including subscription tier and storage usage.
  - `transferEther`: Transfers Ether from the contract to a specified address for payments.
  - `addAddress`: Adds a user address to the system if it does not already exist.

This system design ensures a decentralized and secure mechanism for file storage and management, leveraging the Ethereum blockchain for trustless interactions and data integrity.

## Diagrams

### 1. Store File

   - The user initiates the file storage process by calling the storeFile function in the FileStorageManager contract.
   - storeFile validates user storage limits and file chunks, interacting with UserManager for user data and ChunkManager for file hash validation.
   - It finds available storage nodes for each chunk through NodeManager's findAvailableNode.
   - Each chunk is stored in selected nodes using NodeManager's storeChunkInNode.
   - The file's hash is stored with ChunkManager's storeFileHash.
   - File metadata is saved in FileStorageManager using its storeFileMetadata.
   - The uploader's address is added if not present, using UserManager's addAddress.

![image](https://github.com/Karamveer200/decentralized-storage/assets/68271221/3af803b6-0462-458a-b8a3-bc6a5e99c601)


### 2. Retreive File

   - A user requests to retrieve file details using the retrieveFileDetails function in the FileStorageManager contract.
   - The function fetches the file's metadata from its own storage.
   - It retrieves the addresses of nodes storing the file's chunks through NodeManager's retrieveChunkNodeAddresses.
   - Combines this data to provide the user with the file's metadata and the locations of its chunks for retrieval.

![image](https://github.com/Karamveer200/decentralized-storage/assets/125762319/28a4b1e9-f24c-4814-8866-c4fb8779a745)

## 3. Delete File

   - The user triggers the file deletion by calling deleteFile in the FileStorageManager.
   - deleteFile locates the file and its chunks within its own storage.
   - It calls NodeManager's deleteChunkInNode to remove the chunks from the respective storage nodes.
   - The file's hash is removed using ChunkManager's deleteFileHash.
   - Finally, the file's metadata is removed from FileStorageManager.

![495DeleteFile drawio](https://github.com/Karamveer200/decentralized-storage/assets/125762319/35acb37d-992e-4e75-a92e-188aaa89cc49)




