// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/_FileStorage.sol";
import "../contracts/_ChunkManager.sol";
import "../contracts/_NodeManager.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract TestSuite is FileStorageManager {
    address acc0 = TestsAccounts.getAccount(0); // owner by default
    address acc1 = TestsAccounts.getAccount(1);
    address acc2 = TestsAccounts.getAccount(2);
    address acc3 = TestsAccounts.getAccount(3);

    function beforeAll() public {
        // Add nodes for testing
        addNode(acc1, 500); // Node with 500 storage
        addNode(acc2, 1000); // Node with 1000 storage
        addNode(acc3, 1500); // Node with 1500 storage
    }

    function testStoreAndRetrieveFile() public {
        string[] memory chunksArr = new string[](3); // Explicitly declare the size
        chunksArr[0] = "chunk1";
        chunksArr[1] = "chunk2";
        chunksArr[2] = "chunk3";
        string memory fileName = "example.txt";
        string memory fileType = "text/plain";
        string memory fileEncoding = "UTF-8";
        string memory uniqueId = "123";
        uint256 fileSize = 300;

        // Store file
        address[] memory nodes = storeFile(chunksArr, fileName, fileType, fileEncoding, uniqueId, fileSize);

        // Retrieve file hash
        bytes32 retrievedHash = retrieveFile(0);

        // Validate file authenticity
        Assert.equal(validateFileAuthenticity(retrievedHash, uniqueId), true, "File authenticity not validated");

        // Check if nodes array is not empty
        Assert.notEqual(nodes.length, 0, "Nodes array is empty");

        // Check if the file metadata is stored correctly
        uint256 metadataLength = getFileMetadataLength(acc0);
        Assert.equal(metadataLength, 1, "Incorrect metadata length");

        FileMetadata memory storedMetadata = getFileMetadata(acc0, 0);
        Assert.equal(storedMetadata.fileId, uniqueId, "Incorrect file ID");
        Assert.equal(storedMetadata.fileName, fileName, "Incorrect file name");
        Assert.equal(storedMetadata.fileType, fileType, "Incorrect file type");
        Assert.equal(storedMetadata.fileSize, fileSize, "Incorrect file size");
        Assert.equal(storedMetadata.fileEncoding, fileEncoding, "Incorrect file encoding");
        Assert.equal(storedMetadata.fileStorageNodeAddress.length, nodes.length, "Incorrect number of nodes");
    }

    function testDeleteFile() public {
        // Add nodes for testing
        addNode(acc0, 500); // Node with 500 storage

        // Store a file for testing
        string[] memory chunksArr = new string[](3); // Explicitly declare the size
        chunksArr[0] = "chunk1";
        chunksArr[1] = "chunk2";
        chunksArr[2] = "chunk3";
        string memory fileName = "example.txt";
        string memory fileType = "text/plain";
        string memory fileEncoding = "UTF-8";
        string memory uniqueId = "123";
        uint256 fileSize = 300;

        storeFile(chunksArr, fileName, fileType, fileEncoding, uniqueId, fileSize);

        // Get the initial count of files
        FileMetadata[] memory initialFiles = getFileMetadataArray(acc0);
        uint256 initialFileCount = initialFiles.length;

        // Delete the file
        deleteFile(uniqueId);

        // Get the final count of files
        FileMetadata[] memory finalFiles = getFileMetadataArray(acc0);
        uint256 finalFileCount = finalFiles.length;

        // Check if the file was removed
        Assert.equal(finalFileCount, initialFileCount - 1, "File was not deleted");
    }

    function testFindAvailableNode() public {
        // Test when all nodes have sufficient available storage
        address availableNode1 = findAvailableNode(200);
        Assert.notEqual(availableNode1, acc1, "No available node found");

        // Test when only one node has sufficient available storage
        updateAvailableStorage(acc1, 100); // Reduce available storage for node acc1
        address availableNode2 = findAvailableNode(50);
        Assert.equal(availableNode2, acc2, "Incorrect available node found");

        // Test when no node has sufficient available storage
        updateAvailableStorage(acc2, 200); // Reduce available storage for node acc2
        updateAvailableStorage(acc3, 200); // Reduce available storage for node acc3
        address availableNode3 = findAvailableNode(300);
        Assert.equal(availableNode3, acc3, "Available node found when none should be available");
    }
}
    