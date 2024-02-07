// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";
import "../../contracts/_FileStorage.sol";
import "../../utils/Constants.sol";
import "hardhat/console.sol";

contract DeleteFileTestSuite {
    FileStorageManager fileStorage;

    function beforeAll() public {
        fileStorage = new FileStorageManager();
        fileStorage.addNode(
            Constants.TEST_RANDOM_ADDRESS_1,
            Constants.TEST_RANDOM_NODE_SIZE_10000
        );
        fileStorage.addNode(
            Constants.TEST_RANDOM_ADDRESS_2,
            Constants.TEST_RANDOM_NODE_SIZE_10000
        );
    }

    //Positive
    // Case 1 - Delete a file successfully
    function case1DeleteFile() public {
        // Add a file
        string[] memory chunksArr = new string[](4);
        chunksArr[0] = "abc";
        chunksArr[1] = "def";
        chunksArr[2] = "ghi";
        chunksArr[3] = "jklmnop";

        fileStorage.storeFile(
            chunksArr,
            Constants.TEST_FILE_1_NAME,
            Constants.TEST_FILE_1_TYPE,
            Constants.TEST_FILE_1_ENCODING,
            Constants.TEST_FILE_1_ID,
            Constants.TEST_FILE_1_SIZE
        );

        // Delete the added file
        fileStorage.deleteFile(Constants.TEST_FILE_1_ID);

        // Check if the file is deleted
        bool fileDeleted = true;
        try fileStorage.retrieveFileDetails(Constants.TEST_FILE_1_ID) {
            fileDeleted = false;
        } catch Error(string memory) {
            // Expected error since the file should not be found
        }
        Assert.equal(
            fileDeleted,
            true,
            "case1DeleteFile: File was not deleted"
        );
    }

    //Negative
    // Case 2 - Attempt to delete a non-existent file, expect an error
    function case2DeleteNonExistentFile() public {
        bool errorThrown = false;
        try fileStorage.deleteFile(Constants.TEST_FILE_1_ID) {
            // Should not reach here, as the file does not exist
            revert("case2DeleteNonExistentFile: Unexpected success");
        } catch Error(string memory) {
            // Expected error since the file does not exist
            errorThrown = true;
        }
        Assert.equal(
            errorThrown,
            true,
            "case2DeleteNonExistentFile: Error not thrown for non-existent file"
        );
    }

    //Negative
    // Case 3 - Attempt to delete a file with an invalid file ID, expect an error
    function case3DeleteFileInvalidID() public {
        bool errorThrown = false;
        try fileStorage.deleteFile(Constants.TEST_EMPTY_STRING) {
            // Should not reach here, as the file ID is invalid
            revert("case3DeleteFileInvalidID: Unexpected success");
        } catch Error(string memory) {
            // Expected error since the file ID is invalid
            errorThrown = true;
        }
        Assert.equal(
            errorThrown,
            true,
            "case3DeleteFileInvalidID: Error not thrown for invalid file ID"
        );
    }
}
