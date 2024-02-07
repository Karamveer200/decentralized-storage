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

    mapping(address => Node) internal nodes;

    // Mapping from node address to fileId to chunk data
    mapping(string => address[]) public nodeChunksAddresses;

    address[] public allNodes;


    function addNode(address _nodeAddress, uint256 _initialStorage) public {
        require(
            nodes[address(_nodeAddress)].nodeAddress == address(0),
            "addNode: Invalid _nodeAddress - Node Already exists"
        );

        // Create a new Node and initialize it
        nodes[address(_nodeAddress)] = Node({
            nodeAddress: address(_nodeAddress),
            availableStorage: _initialStorage
        });
        emit logAddress(address(_nodeAddress)); //added for debugging
        allNodes.push(address(_nodeAddress));
    }

    function updateAvailableStorage(address _nodeAddress, uint256 _newStorage)                  
        internal
    {
        require(
            nodes[_nodeAddress].nodeAddress != address(0),
            "updateAvailableStorage: Invalid _nodeAddress - Node Does NOT exist"
        );
        nodes[_nodeAddress].availableStorage = _newStorage;
    }

    function storeChunkInNode(                  
        address _nodeAddress,
        uint256 _chunkSize,
        string memory _fileId,
        string memory _chunkHash
    ) internal {
        require(
            nodes[_nodeAddress].nodeAddress != address(0),
            "storeChunkInNode: Invalid _nodeAddress - Node Does NOT exist"
        );

        // Store the chunk data in the separate mapping for the given fileId and node address
        if (!isAddressPresent(_nodeAddress, nodeChunksAddresses[_fileId])) {
            nodeChunksAddresses[_fileId].push(_nodeAddress);

            // Update available storage of the current node
            updateAvailableStorage(
                _nodeAddress,
                nodes[_nodeAddress].availableStorage - _chunkSize
            );
        }
    }

    function retrieveChunkNodeAddresses(string memory _fileId)
        public
        view
        returns (address[] memory)
    {
        require(
            nodeChunksAddresses[_fileId].length > 0,
            "retrieveChunkNodeAddresses: Invalid _nodeAddress - Node Does NOT exist"
        );

        // Retrieve and return the chunk data from the separate mapping for the given fileId and node address
        return nodeChunksAddresses[_fileId];
    }

    function deleteChunkInNode(string memory _fileId) internal {
        require(
            bytes(_fileId).length > 0,
            "deleteChunkInNode: Invalid _fileId"
        );

        // Delete the chunk data from the separate mapping for the given fileId and node address
        delete nodeChunksAddresses[_fileId];
    }

    function getAllNodes() internal  view returns (address[] memory) {     
        return allNodes;
    }

    function getNodeByAddress(address _nodeAddress)                             
        internal
        view
        returns (Node memory)
    {
        return nodes[_nodeAddress];
    }

    function findAvailableNode(
        uint256 _chunkSize,
        address[] memory chunkStorageNodeTempAddress
    ) internal returns (address) {
        uint256 numNodes = allNodes.length;
        uint256 sizeOffset = 50;

        if (numNodes == 0) {
            return address(0);
        }

        // Generate a pseudo-random index using blockhash
        uint256 randomIndex = uint256(blockhash(block.number - 1)) % numNodes;
        uint256 i = 0;
        uint256 loopTimeoutCount = 0;
        uint256 BREAK_LOOP_COUNT = 1000;

        // Iterate through the nodes starting from the pseudo-random index
        while (loopTimeoutCount < BREAK_LOOP_COUNT) {
            address node = allNodes[(randomIndex + i) % numNodes];
            emit logNumber(randomIndex);

            if (nodes[node].availableStorage > _chunkSize + sizeOffset) {
                bool isUniqueNode = true;

                for (
                    uint256 j = 0;
                    j < chunkStorageNodeTempAddress.length;
                    j++
                ) {
                    if (chunkStorageNodeTempAddress[j] == node) {
                        isUniqueNode = false;
                    }
                }

                if (isUniqueNode) {
                    // Randomly return the first unique node found with available storage
                    loopTimeoutCount = BREAK_LOOP_COUNT;
                    return node;
                }
            }

            i++;
            loopTimeoutCount++;

            if (i == numNodes) {
                i = 0;
            }
        }
        // No available nodes
        return address(0);
    }

    function isAddressPresent(
        address nodeAddress,
        address[] memory fileStorageNodeAddresses
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < fileStorageNodeAddresses.length; i++) {
            if (fileStorageNodeAddresses[i] == nodeAddress) {
                return true;
            }
        }
        return false;
    }
}
