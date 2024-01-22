// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 
import "../contracts/_FileStorage.sol";

contract FileStorageTest {
    // Instance of FileStorageManager
    FileStorageManager fileStorage;

    // Runs before all tests
    function beforeAll() public {
        // Create an instance of FileStorageManager
        fileStorage = new FileStorageManager();
    }

    event logString(string);

    // Test storing and retrieval of a file, but retreival is not working right now
    function testStoreFile() public {
        string memory fileName = "test.txt";
        string memory content = "content.";
        string memory uniqueId = "123";

        // Store a file
        fileStorage.storeFile(fileName, content, uniqueId);

        // Retrieve the stored file content
        string memory retrievedContent = fileStorage.retrieveFile(uniqueId);

        // Assert the correctness of the retrieved content
        emit logString(retrievedContent);
        Assert.equal(retrievedContent, content, "Incorrect retrieved content");
    }

    // // Test deleting a file , Currently retreival is not working, so cant test deletion without it.
    // function testDeleteFile() public {
    //     string memory uniqueId = "123";

    //     // Delete the file
    //     fileStorage.deleteFile(uniqueId);

    //     // Attempt to retrieve the deleted file
    //     string memory retrievedContent = fileStorage.retrieveFile(uniqueId);

    //     // Check if the retrieval failed (assuming an empty string indicates failure)
    //     bool retrievalFailed = bytes(retrievedContent).length == 0;

    //     // Assert that retrieval fails after deletion
    //     Assert.equal(retrievalFailed, true, "Retrieval after deletion should fail");
    // }
}
    