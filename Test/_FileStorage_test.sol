// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/_FileStorage.sol";

contract FileStorageTest {
    // Instance of FileStorageManager
    FileStorageManager fileStorage;

    // Runs before all tests
    function beforeAll() public {
        // Create an instance of FileStorageManager
        fileStorage = new FileStorageManager();
    }

    // Test storing a file
    function testStoreFile() public {
        string memory fileName = "test.txt";
        string memory content = "This is a test content.";
        string memory uniqueId = "123";

        // Store a file
        fileStorage.storeFile(fileName, content, uniqueId);

        // Retrieve the stored file content
        string memory retrievedContent = fileStorage.retrieveFile(uniqueId);

        // Assert the correctness of the retrieved content
        Assert.equal(retrievedContent, content, "Incorrect retrieved content");
    }

    // Test deleting a file
    function testDeleteFile() public {
        string memory uniqueId = "123";

        // Delete the file
        fileStorage.deleteFile(uniqueId);

        // Attempt to retrieve the deleted file
        string memory retrievedContent = fileStorage.retrieveFile(uniqueId);

        // Check if the retrieval failed (assuming an empty string indicates failure)
        bool retrievalFailed = bytes(retrievedContent).length == 0;

        // Assert that retrieval fails after deletion
        Assert.equal(retrievalFailed, true, "Retrieval after deletion should fail");
    }
}
    