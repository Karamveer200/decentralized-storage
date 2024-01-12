// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";

contract FileStorageManager is ChunkManager, NodeManager {
    address public owner;

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

    constructor() NodeManager() {
        owner = msg.sender;
    }

    function storeFile(string memory fileName, string memory content, string memory uniqueId) public {
        uint256 fileSize = bytes(content).length;

        fileIdToMetadata[uniqueId] = FileMetadata(fileName, fileSize);

        // Chunk the content and store the chunk IDs
        string[] memory chunks = chunkContent(content);
        fileIdToChunks[uniqueId] = chunks;

        // Iterate through each chunk and distribute them to nodes
        for (uint256 i = 0; i < chunks.length; i++) {
            uint256 chunkSize = bytes(chunks[i]).length;
            address selectedNodeAddress = findAvailableNode(chunkSize);

            require(selectedNodeAddress != address(0), "No available nodes");
            fileIdToNode[uniqueId].push(selectedNodeAddress);

            storeChunkInNode(selectedNodeAddress, chunks[i]);

            // Update available storage of the current node
            updateAvailableStorage(selectedNodeAddress, nodes[selectedNodeAddress].availableStorage - chunkSize);
        }
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

        // Also call File deletion in the node itself

        // Delete file metadata, node mapping, and chunks
        delete fileIdToMetadata[fileId];
        delete fileIdToNode[fileId];
        delete fileIdToChunks[fileId];
    }
}