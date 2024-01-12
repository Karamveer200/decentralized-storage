// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";

contract FileStorageManager is ChunkManager, NodeManager {
    address public owner;

    // Mapping from fileId to FileMetadata  
    mapping(string => FileMetadata) private fileIdToMetadata;

    // Mapping from fileId to storage node
    mapping(string => address[]) private fileIdToNodesAddresses;

    struct FileMetadata {
        string fileName;
        uint256 fileSize;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthenticated");
        _;
    }

    constructor() NodeManager() {
        owner = msg.sender;
    }

    function storeFile(string memory fileName, string memory content, string memory uniqueId) public {
        uint256 fileSize = bytes(content).length;

        fileIdToMetadata[uniqueId] = FileMetadata(fileName, fileSize);

        // Chunk the content and store the chunk IDs
        string[] memory chunks = chunkContent(content);

        // Iterate through each chunk and distribute them to nodes
        for (uint256 i = 0; i < chunks.length; i++) {
            uint256 chunkSize = bytes(chunks[i]).length;
            address selectedNodeAddress = findAvailableNode(chunkSize);

            require(selectedNodeAddress != address(0), "No available nodes");
            fileIdToNodesAddresses[uniqueId].push(selectedNodeAddress);

            storeChunkInNode(selectedNodeAddress, chunks[i]);

            // Update available storage of the current node
            updateAvailableStorage(selectedNodeAddress, nodes[selectedNodeAddress].availableStorage - chunkSize);
        }
    }

    function retrieveFile(string memory fileId) public view returns (string memory) {
        require(fileIdToMetadata[fileId].fileSize > 0, "File not found");

        // Retrieve chunks from storage nodes
        address[] memory storageNodes = fileIdToNodesAddresses[fileId];
        string [] memory chunksArr;

        for (uint256 i = 0; i < storageNodes.length; i++) {
            // address selectedNodeAddress = storageNodes[i];

            // chunksArr.push(retrieveChunkInNode(selectedNodeAddress, fileId));
        }

        // Concatenate chunks into a single string
        string memory concatenatedContent = concatenateChunks(chunksArr);

        return concatenatedContent;
    }

    function deleteFile(string memory fileId) public {
        require(fileIdToMetadata[fileId].fileSize > 0, "File not found");
        require(msg.sender == owner, "Unauthorized");

        address[] memory storageNodes = fileIdToNodesAddresses[fileId];

        // Deletion of chunk in the node itself
        for (uint256 i = 0; i < storageNodes.length; i++) {
            address selectedNodeAddress = storageNodes[i];
            deleteChunkInNode(selectedNodeAddress, fileId);
        }

        // Delete file metadata, node mapping, and chunks
        delete fileIdToMetadata[fileId];
        delete fileIdToNodesAddresses[fileId];
    }
}