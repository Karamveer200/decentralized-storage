// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_UserManager.sol";

contract NodeManager is UserManager {
    struct Node {
        address nodeAddress;
        uint256 availableStorage;
        uint256 stakedAmount;
    }

    mapping(address => Node) internal nodes;

    // Mapping to track payments for each storage node
    mapping(address => uint256) internal nodePayments;

    // Mapping to track staking amounts for each node
    mapping(address => uint256) internal nodeStakes;

    // Mapping from node address to fileId to chunk data
    mapping(string => address[]) public nodeChunksAddresses;

    address[] public allNodes;

    // Mapping to track whether a node is flagged as a bad actor
    mapping(address => bool) internal badActors;

    // Event for staking by storage nodes
    event NodeStaked(address indexed node, uint256 amount);

    // Event for storage payment
    event StorageNodePaid(address indexed storageNode, uint256 amount);

    // Function to stake and register a new storage node
    function addNode() public payable {
        // Check if the node is not already registered
        require(
            nodes[msg.sender].nodeAddress == address(0),
            "addNode: Node already registered."
        );

        // Enforce staking amount, random placeholder value
        require(msg.value < 50 gwei, "Incorrect staking amount.");

        // Create a new Node and initialize it
        nodes[msg.sender] = Node({
            nodeAddress: msg.sender,
            availableStorage: 0,
            stakedAmount: msg.value
        });

        // Track the staking amount
        nodeStakes[msg.sender] = msg.value;

        // Add the node to the list of all nodes
        allNodes.push(msg.sender);

        // Emit an event for staking
        emit NodeStaked(msg.sender, msg.value);
    }

    // Function to pay storage nodes based on proof of storage
    function payStorageNodes() internal {
        // Distribute payments to storage nodes based on proof of storage
        for (uint256 i = 0; i < allNodes.length; i++) {
            address storageNode = allNodes[i];

            // Calculate payment somehow, not exactly sure for now random amount, do heartbeat checks and random sampling

            uint256 paymentAmount = 5;

            // Make payment to the storage node
            payable(storageNode).transfer(paymentAmount);

            // Update payment tracking
            nodePayments[storageNode] += paymentAmount;

            // Emit an event for storage payment
            emit StorageNodePaid(storageNode, paymentAmount);
        }
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

    function getAllNodes() internal view returns (address[] memory) {
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
    ) internal view returns (address) {
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

    function getNodeAvailableStorage(address _nodeAddress)
        internal
        view
        returns (uint256)
    {
        return nodes[_nodeAddress].availableStorage;
    }

    // Event for deleting a storage node
    event NodeDeleted(
        address indexed storageNode,
        uint256 initialStake,
        uint256 remainingPayments
    );

    // Function to delete a storage node, returning the initial stake and remaining payments
    function deleteNode() external {
        address storageNode = msg.sender;
        // Check if the node is flagged as a bad actor
        require(!isBadActor(storageNode), "Node flagged as a bad actor.");

        // Retrieve the initial stake and remaining payments
        uint256 initialStake = nodeStakes[storageNode];
        uint256 remainingPayments = nodePayments[storageNode];

        // Transfer the initial stake and remaining payments to the storage node
        payable(storageNode).transfer(initialStake + remainingPayments);

        // need to also add a function to remove the storage node from mapping

        // Emit an event for node deletion
        emit NodeDeleted(storageNode, initialStake, remainingPayments);
    }

    // Function to check whether a node is flagged as a bad actor
    function isBadActor(address storageNode) internal view returns (bool) {
        return badActors[storageNode]; //needs some policy later
    }
}
