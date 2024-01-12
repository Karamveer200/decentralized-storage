// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract NodeManager {
    struct Node {
        address nodeAddress;
        uint256 availableStorage;
    }

    mapping(address => Node) public nodes;
    address[] public allNodes;

    function addNode(address _nodeAddress, uint256 _initialStorage) public {
        require(nodes[_nodeAddress].nodeAddress == address(0), "Node already exists");
        nodes[_nodeAddress] = Node(_nodeAddress, _initialStorage);
        allNodes.push(_nodeAddress);
    }

    function updateAvailableStorage(address _nodeAddress, uint256 _newStorage) public {
        require(nodes[_nodeAddress].nodeAddress != address(0), "Node does not exist");
        nodes[_nodeAddress].availableStorage = _newStorage;
    }

    function storeChunkInNode(address _nodeAddress, string memory _chunk) public {
        // TODO: Store the chunk in Node
    }

    function retrieveChunkInNode(address _nodeAddress, string memory _fileId) public view returns (string memory) {
        // TODO: Retrieve the chunk in Node
    }

    function deleteChunkInNode(address _nodeAddress, string memory _fileId) public view returns (string memory) {
        // TODO: Delete the chunk in Node
    }

    function getAllNodes() public view returns (address[] memory) {
        return allNodes;
    }

    function getNodeByAddress(address _nodeAddress) public view returns (Node memory) {
        return nodes[_nodeAddress];
    }

    function findAvailableNode(uint256 _chunkSize) internal view returns (address) {
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
            if (nodes[node].availableStorage > _chunkSize + sizeOffset) {
                // Randomly return the first node found with available storage
                return node;
            }
        }
        // No available nodes
        return address(0); 
    }
}