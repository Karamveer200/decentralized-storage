// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol";
import "../../contracts/_FileStorage.sol";
import "../_AccessInternalFunctions.sol";
import "../../utils/Constants.sol";

contract PositiveFileStorageTestSuite {
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

    // Positive Case: Retrieve file details for an existing file
    function positiveCase1RetrieveFileDetails() public {
        // Store a file first to have something to retrieve
        uint256[] memory chunksSizeArr = new uint256[](4);
        chunksSizeArr[0] = 10;
        chunksSizeArr[1] = 20;
        chunksSizeArr[2] = 30;
        chunksSizeArr[3] = 40;

        string[] memory chunksHashesArr = new string[](4);
        chunksHashesArr[0] = "127125$1821";
        chunksHashesArr[1] = "91768612$1212";
        chunksHashesArr[2] = "1@72673512@%$";
        chunksHashesArr[3] = "0188712$1812";

        fileStorage.storeFile(
            chunksSizeArr,
            Constants.TEST_FILE_1_NAME,
            Constants.TEST_FILE_1_TYPE,
            Constants.TEST_FILE_1_ENCODING,
            Constants.TEST_FILE_1_ID,
            Constants.TEST_FILE_1_SIZE,
            Constants.TEST_FILE_1_HASH,
            chunksHashesArr
        );
        bytes32 getFileHash = bytes32("hash");

        address[] memory nodeAddressOfStoredChunk = fileStorage
            .retrieveChunkNodeAddresses(Constants.TEST_FILE_1_ID);

        FileStorageManager.FileRetrieve memory expectedFile = FileStorageManager
            .FileRetrieve(
                FileStorageManager.FileMetadata(
                    Constants.TEST_FILE_1_ID,
                    Constants.TEST_FILE_1_NAME,
                    Constants.TEST_FILE_1_TYPE,
                    getFileHash,
                    Constants.TEST_FILE_1_SIZE,
                    block.timestamp,
                    msg.sender,
                    Constants.TEST_FILE_1_ENCODING
                ),
                nodeAddressOfStoredChunk,
                chunksHashesArr
            );

        // Check if the retrieved file details match the expected values
        Assert.equal(
            fileStorage
                .retrieveFileDetails(Constants.TEST_FILE_1_ID)
                .file
                .fileId,
            expectedFile.file.fileId,
            "File ID should match the expected value"
        );

        Assert.equal(
            fileStorage
                .retrieveFileDetails(Constants.TEST_FILE_1_ID)
                .file
                .fileName,
            expectedFile.file.fileName,
            "File name should match the expected value"
        );

        Assert.equal(
            fileStorage
                .retrieveFileDetails(Constants.TEST_FILE_1_ID)
                .file
                .fileType,
            expectedFile.file.fileType,
            "File type should match the expected value"
        );

        // Check if the chunk node addresses array is not empty
        Assert.equal(
            nodeAddressOfStoredChunk.length > 0,
            true,
            "Chunk node addresses should not be empty"
        );
    }
}

contract NegativeFileStorageTestSuite {
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

    // Negative Case: Attempt to retrieve details for a non-existing file
    function negativeCase1RetrieveFileDetailsNonExisting() public {
        // Use a non-existing file ID
        string memory nonExistingFileId = "nonExistingFile";

        // Attempt to retrieve file details
        bool flag = false;
        try fileStorage.retrieveFileDetails(nonExistingFileId) {
            flag = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.RETRIEVE_FILE_DETAILS_FILE_NOT_FOUND,
                "Unexpected error message for non-existing file"
            );
        }
        Assert.equal(flag, false, "Should fail for non-existing file");
    }
}
