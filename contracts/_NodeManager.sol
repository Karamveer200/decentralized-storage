// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract NodeManager {
    struct Node {
        address nodeAddress;
        uint256 availableStorage;
    }

    event logAddress(address);
    event logAddress2(address);
    event logNumber(uint256);


    mapping(address => Node) public nodes;
    mapping(address => mapping(string => string)) public nodeChunks; // Mapping from node address to fileId to chunk data
    address[] public allNodes;

    //

    function addNode(address _nodeAddress, uint256 _initialStorage) public {
        require(nodes[address(_nodeAddress)].nodeAddress == address(0), "Node already exists");
        
        // Create a new Node and initialize it
        nodes[address(_nodeAddress)] = Node({
            nodeAddress: address(_nodeAddress),
            availableStorage: _initialStorage
        });
        emit logAddress(address(_nodeAddress)); //added for debugging
        allNodes.push(address(_nodeAddress));
    }

    function updateAvailableStorage(address _nodeAddress, uint256 _newStorage) internal {
        require(nodes[_nodeAddress].nodeAddress != address(0), "Node does not exist");
        nodes[_nodeAddress].availableStorage = _newStorage;
    }

    function storeChunkInNode(address _nodeAddress, string memory _chunk, string memory _fileId) public {
        require(nodes[_nodeAddress].nodeAddress != address(0), "Node does not exist");

        // Store the chunk data in the separate mapping for the given fileId and node address
        nodeChunks[_nodeAddress][_fileId] = _chunk;
    }

    function retrieveChunkInNode(address _nodeAddress, string memory _fileId) public view returns (string memory) {
        require(nodes[_nodeAddress].nodeAddress != address(0), "Node does not exist");

        // Retrieve and return the chunk data from the separate mapping for the given fileId and node address
        return nodeChunks[_nodeAddress][_fileId];
    }

    function deleteChunkInNode(address _nodeAddress, string memory _fileId) public {
        require(nodes[_nodeAddress].nodeAddress != address(0), "Node does not exist");

        // Delete the chunk data from the separate mapping for the given fileId and node address
        delete nodeChunks[_nodeAddress][_fileId];
    }

    function getAllNodes() public view returns (address[] memory) {
        return allNodes;
    }

    function getNodeByAddress(address _nodeAddress) public view returns (Node memory) {
        return nodes[_nodeAddress];
    }

    function findAvailableNode(uint256 _chunkSize) public returns (address) {
        uint256 numNodes = allNodes.length;
        uint256 sizeOffset = 50;

        if (numNodes == 0) {
            return address(0);
        }

        // Generate a pseudo-random index using blockhash
        uint256 randomIndex = uint256(blockhash(block.number - 1)) % numNodes;

        // Iterate through the nodes starting from the pseudo-random index
        for (uint256 i = 0; i < numNodes; i++) {
            address node = allNodes[(randomIndex + i) % numNodes];
            emit logNumber(randomIndex);
            if (nodes[node].availableStorage > _chunkSize + sizeOffset) {
                // Randomly return the first node found with available storage
                return node;
            }
        }
        // No available nodes
        return address(0); 
    }
}