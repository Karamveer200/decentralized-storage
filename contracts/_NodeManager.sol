// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract NodeManager {
    struct Node {
        address nodeAddress;
        uint256 availableStorage;
        uint256 stakedAmount;
    }

    mapping(address => Node) public nodes;

    // Mapping from fileId to node address chunk data
    mapping(string => address[]) public nodeChunksAddresses;

    address[] public allNodes;

    // Mapping to track whether a node is flagged as a bad actor
    mapping(address => bool) public badActors;
    mapping(address => uint256[]) public badActorTimestamps;

    uint256 initialStake = 50 gwei;

    // Function to stake and register a new storage node
    function addNode(address _nodeAddress, uint256 _initialStorage)
        public
        payable
    {
        console.log("Amount recieved - ", initialStake, msg.value);

        // Check if the node is not already registered
        require(
            nodes[_nodeAddress].nodeAddress == address(0),
            "addNode: Invalid _nodeAddress - Node Already exists"
        );

        // Enforce staking amount, random placeholder value
        require(msg.value == initialStake, "Incorrect staking amount.");
        nodes[address(_nodeAddress)] = Node({
            nodeAddress: address(_nodeAddress),
            availableStorage: _initialStorage,
            stakedAmount: msg.value
        });

        // Add the node to the list of all nodes
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

        console.log("_chunkHash", _chunkHash);

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
    ) public view returns (address) {
        uint256 numNodes = allNodes.length;
        uint256 sizeOffset = 50;

        if (numNodes == 0) {
            return address(0);
        }

        // Generate a pseudo-random index using blockhash
        uint256 randomIndex = uint256(blockhash(block.number - 1)) % numNodes;
        uint256 i = 0;
        uint256 loopTimeoutCount = 0;
        uint256 BREAK_LOOP_COUNT = 80;

        if (chunkStorageNodeTempAddress.length == allNodes.length) {
            return address(0);
        }

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

    // Function to delete a storage node, returning the initial stake and remaining payments
    function returnInitialStake(address payee) external {
        require(!isBadActor(payee), "Node flagged as a bad actor.");

        payable(payee).transfer(initialStake);
    }

    // Function to check whether a node is flagged as a bad actor
    function isBadActor(address storageNode) public view returns (bool) {
        return badActors[storageNode]; //needs some policy later
    }

    function flagAsBadActor(address _nodeAddress) public {
        // Assuming onlyOwner or similar modifier is used to restrict access
        require(
            !badActors[_nodeAddress],
            "Node is already flagged as a bad actor."
        );
        require(
            nodes[_nodeAddress].nodeAddress != address(0),
            "flagAsBadActor: Invalid _nodeAddress - Node Does NOT exist"
        );

        badActors[_nodeAddress] = true;
        badActorTimestamps[_nodeAddress].push(block.timestamp);
    }

    function chargePenaltyForBadActors(address _nodeAddress) public {
        uint256 incidentCounts = badActorTimestamps[_nodeAddress].length;
        uint256 stakedAmount = nodes[_nodeAddress].stakedAmount;

        if (stakedAmount > 0) {
            // 10% penalty for each inactivity
            uint256 calculatePenalty = incidentCounts *
                ((stakedAmount * 10) / 100);

            if (calculatePenalty > stakedAmount) {
                nodes[_nodeAddress].stakedAmount = 0;
            } else {
                nodes[_nodeAddress].stakedAmount =
                    stakedAmount -
                    calculatePenalty;
            }
        }
    }

    function getNodeContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
