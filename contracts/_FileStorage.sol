// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./_ChunkManager.sol";

contract FileStorageManager is ChunkManager {
    address public owner;
    uint256 public availableStorage;

    // Mapping from fileId to FileMetadata  
    mapping(string => FileMetadata) private fileIdToMetadata;

    // Mapping from fileId to storage node
    mapping(string => address[]) private fileIdToNode;

    // Mapping from fileId to chunks
    mapping(string => string[]) private fileIdToChunks; 

    struct FileMetadata {
        string fileName;
        uint256 fileSize;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthenticated");
        _;
    }

    constructor(uint256 initialStorage) {
        owner = msg.sender;
        availableStorage = initialStorage;
    }

    function storeFile(string memory fileName, string memory content, string memory uniqueId, address[] memory storageNodes) public {
        uint256 fileSize = bytes(content).length;

        require(availableStorage >= fileSize, "No storage available");
        require(storageNodes.length > 0, "At least one storage node is required");

        
        fileIdToMetadata[uniqueId] = FileMetadata(fileName, fileSize);

        // Chunk the content and store the chunk IDs
        string[] memory chunks = chunkContent(content);
        fileIdToChunks[uniqueId] = chunks;

        // Calculate how many nodes each chunk should be stored in
        uint256 nodesPerChunk = storageNodes.length / chunks.length;
        uint256 remainingNodes = storageNodes.length % chunks.length;

        uint256 currentIndex = 0;

        // Iterate through each chunk and distribute them to nodes
        for (uint256 i = 0; i < chunks.length; i++) {
            uint256 nodesToUse = nodesPerChunk;
            
            // If there are remaining nodes, use one extra node for each remaining chunk
            if (remainingNodes > 0) {
                nodesToUse++;
                remainingNodes--;
            }

            // Store the chunk in the selected nodes
            for (uint256 j = 0; j < nodesToUse; j++) {
                // Logic for actually storing chunk in the node
                currentIndex++;
            }
        }
        availableStorage -= fileSize;
    }

    function retrieveFile(string memory fileId) public view returns (string memory) {
        require(fileIdToMetadata[fileId].fileSize > 0, "File not found");

        // Retrieve chunks from storage nodes
        string[] memory chunks = fileIdToChunks[fileId];
        require(chunks.length > 0, "No chunks found for the file");

        // Concatenate chunks into a single string
        string memory concatenatedContent = concatenateChunks(chunks);

        return concatenatedContent;
    }

    function deleteFile(string memory fileId) public {
        require(fileIdToMetadata[fileId].fileSize > 0, "File not found");
        require(msg.sender == owner, "Unauthorized");

        uint256 fileSize = fileIdToMetadata[fileId].fileSize;
        availableStorage += fileSize;

        // Also call File deletion in the node itself

        // Delete file metadata, node mapping, and chunks
        delete fileIdToMetadata[fileId];
        delete fileIdToNode[fileId];
        delete fileIdToChunks[fileId];


    }
}