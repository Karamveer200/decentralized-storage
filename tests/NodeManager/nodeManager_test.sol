// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol";
import "../../contracts/_FileStorage.sol";
import "../_AccessInternalFunctions.sol";
import "../../utils/Constants.sol";

contract NodeManagerPositiveTestSuite {
    NodeManager nodeManager;
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        nodeManager = new NodeManager();
        accessInternalFuncitons = new AccessInternalFunctions();
    }

    // Positive Case: Add a new node and check if it exists
    function positiveCase1AddNode() public {
        (bool success, ) = address(accessInternalFuncitons).call{
            value: 50 gwei
        }(
            abi.encodeWithSignature(
                "accessInternalFuncitons.addNodeDerived(address,uint256)",
                Constants.TEST_RANDOM_ADDRESS_1,
                Constants.TEST_RANDOM_NODE_SIZE_10000
            )
        );

        Assert.ok(success, "addNode should succeed");

        // accessInternalFuncitons.addNodeDerived(
        //     Constants.TEST_RANDOM_ADDRESS_1,
        //     Constants.TEST_RANDOM_NODE_SIZE_10000
        // );

        NodeManager.Node memory addedNode = accessInternalFuncitons
            .getNodeByAddressDerived(Constants.TEST_RANDOM_ADDRESS_1);

        Assert.equal(
            addedNode.nodeAddress,
            Constants.TEST_RANDOM_ADDRESS_1,
            "positiveCase1AddNode: Failed to add node"
        );
    }

    // Positive Case: Retrieve all nodes and check if the count is correct
    function positiveCase2GetAllNodes() public {
        address[] memory allNodes = accessInternalFuncitons
            .getAllNodesDerived();

        Assert.equal(
            allNodes.length,
            1,
            "positiveCase2GetAllNodes: Incorrect number of nodes"
        );
    }
}

contract NodeManagerPositiveTestSuite2 {
    NodeManager nodeManager;
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        nodeManager = new NodeManager();
        accessInternalFuncitons = new AccessInternalFunctions();
    }

    // Positive Case: Store a chunk in a node and check if it exists in the node's chunks
    function positiveCase3StoreChunkInNode() public {
        accessInternalFuncitons.addNodeDerived(
            Constants.TEST_RANDOM_ADDRESS_2,
            Constants.TEST_RANDOM_NODE_SIZE_10000
        );

        uint256 chunkSize = 200;

        accessInternalFuncitons.storeChunkInNodeDerived(
            Constants.TEST_RANDOM_ADDRESS_2,
            chunkSize,
            "dummyFileId",
            "hash"
        );

        address[] memory nodeChunks = accessInternalFuncitons
            .retrieveChunkNodeAddressesDerived("dummyFileId");

        NodeManager.Node memory addedNode = accessInternalFuncitons
            .getNodeByAddressDerived(Constants.TEST_RANDOM_ADDRESS_2);

        Assert.equal(
            addedNode.availableStorage,
            Constants.TEST_RANDOM_NODE_SIZE_10000 - chunkSize,
            "positiveCase3StoreChunkInNode: Failed to store chunk in node"
        );

        Assert.equal(
            nodeChunks[0],
            Constants.TEST_RANDOM_ADDRESS_2,
            "positiveCase3StoreChunkInNode: Failed to store chunk in node"
        );
    }
}

contract NodeManagerNegativeTestSuite {
    NodeManager nodeManager;
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        nodeManager = new NodeManager();
        accessInternalFuncitons = new AccessInternalFunctions();
    }

    // Negative Case: Try to update available storage for a non-existent node
    function negativeCase1UpdateInvalidNode() public {
        bool flag = false;
        try
            accessInternalFuncitons.updateAvailableStorageDerived(
                Constants.TEST_RANDOM_ADDRESS_1,
                Constants.TEST_RANDOM_NODE_SIZE_5000
            )
        {
            flag = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                "updateAvailableStorage: Invalid _nodeAddress - Node Does NOT exist",
                "negativeCase1UpdateInvalidNode: Failed with unexpected reason"
            );
        }
        Assert.equal(
            flag,
            false,
            "negativeCase1UpdateInvalidNode did not work as expected"
        );
    }

    // Negative Case: Try to store a chunk in a non-existent node
    function negativeCase2StoreChunkInInvalidNode() public {
        bool flag = false;
        try
            accessInternalFuncitons.storeChunkInNodeDerived(
                Constants.TEST_RANDOM_ADDRESS_1,
                10,
                "dummyFileId",
                "hash"
            )
        {
            flag = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                "storeChunkInNode: Invalid _nodeAddress - Node Does NOT exist",
                "negativeCase2StoreChunkInInvalidNode: Failed with unexpected reason"
            );
        }
        Assert.equal(
            flag,
            false,
            "negativeCase2StoreChunkInInvalidNode did not work as expected"
        );
    }
}
