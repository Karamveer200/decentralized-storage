// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/_NodeManager.sol";

contract NodeManagerTest {
    // Instance of NodeManager
    NodeManager nodeManager;

    // Runs before all tests
    function beforeAll() public {
        // Create an instance of NodeManager
        nodeManager = new NodeManager();
    }

    // Test adding a new node
    function testAddNode() public {
        address nodeAddress = address(0x1);
        uint256 initialStorage = 100;

        // Add a new node
        nodeManager.addNode(nodeAddress, initialStorage);

        // Retrieve the added node
        NodeManager.Node memory addedNode = nodeManager.getNodeByAddress(nodeAddress);

        // Assert the correctness of the added node
        Assert.equal(addedNode.nodeAddress, nodeAddress, "Incorrect node address");
        Assert.equal(addedNode.availableStorage, initialStorage, "Incorrect initial storage");
    }

    // Test updating available storage
    function testUpdateAvailableStorage() public {
        address nodeAddress = address(0x1);
        uint256 newStorage = 80;

        // Update available storage for the node
        nodeManager.updateAvailableStorage(nodeAddress, newStorage);

        // Retrieve the updated node
        NodeManager.Node memory updatedNode = nodeManager.getNodeByAddress(nodeAddress);

        // Assert the correctness of the updated node
        Assert.equal(updatedNode.availableStorage, newStorage, "Incorrect updated storage");
    }

    // Test finding an available node
    function testFindAvailableNode() public {
        address nodeAddress = address(0x1);
        uint256 chunkSize = 50;

        // Add a new node
        nodeManager.addNode(nodeAddress, 100);

        // Find an available node
        address availableNode = nodeManager.findAvailableNode(chunkSize);

        // Assert that an available node is found
        Assert.notEqual(availableNode, address(0), "No available nodes found");
    }
}