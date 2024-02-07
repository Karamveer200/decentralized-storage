// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";
import "../../contracts/_FileStorage.sol";
import "../../utils/Constants.sol";
import "hardhat/console.sol";

// NEGATIVE SUITE
contract StoreFileTestSuite1 {
    FileStorageManager fileStorage;

    function beforeAll() public {
        fileStorage = new FileStorageManager();
    }

    // Case 1 - Expected to go to catch block as storeFile is called when allNodes.length == 0
    function suite1Case1StoreFile() public {
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

        bool r = false;
        try
            fileStorage.storeFile(
                chunksSizeArr,
                Constants.TEST_FILE_1_NAME,
                Constants.TEST_FILE_1_TYPE,
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_FILE_1_ID,
                Constants.TEST_FILE_1_SIZE,
                Constants.TEST_FILE_1_HASH,
                chunksHashesArr
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_NO_NODES_FOUND,
                "suite1Case1StoreFile: Failed with unexpected reason"
            );
        }
        Assert.equal(r, false, "suite1Case1StoreFile did not work as expected");
    }
}

// POSITIVE SUITE
contract StoreFileTestSuite2 {
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

    // Case 1 - Add two nodes and test store file, expected to store File Id in nodeAddress and File metadata
    function suite2Case1StoreNewFile() public {
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

        address[] memory nodeAddressOfStoredChunk = fileStorage
            .retrieveChunkNodeAddresses(Constants.TEST_FILE_1_ID);

        FileStorageManager.FileRetrieve memory expectedFile = FileStorageManager
            .FileRetrieve(
                FileStorageManager.FileMetadata(
                    Constants.TEST_FILE_1_ID,
                    Constants.TEST_FILE_1_NAME,
                    Constants.TEST_FILE_1_TYPE,
                    Constants.TEST_FILE_1_HASH,
                    Constants.TEST_FILE_1_SIZE,
                    block.timestamp,
                    msg.sender,
                    Constants.TEST_FILE_1_ENCODING
                ),
                nodeAddressOfStoredChunk,
                chunksHashesArr
            );

        Assert.greaterThan(
            nodeAddressOfStoredChunk.length,
            uint256(0),
            "suite2Case1StoreNewFile did not work as expected"
        );

        Assert.equal(
            fileStorage
                .retrieveFileDetails(Constants.TEST_FILE_1_ID)
                .file
                .fileId,
            expectedFile.file.fileId,
            "suite2Case1StoreNewFile did not work as expected"
        );
    }
}

// NEGATIVE SUITE
contract StoreFileTestSuite3 {
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

    // Case 1 - Add two file with same file id, expected to revert due to duplicate id
    function suite3Case1StoreduplicateFile() public {
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

        bool r = false;
        try
            fileStorage.storeFile(
                chunksSizeArr,
                Constants.TEST_FILE_1_NAME,
                Constants.TEST_FILE_1_TYPE,
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_FILE_1_ID,
                Constants.TEST_FILE_1_SIZE,
                Constants.TEST_FILE_1_HASH,
                chunksHashesArr
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_DUPLICATE_FILE_ID,
                "suite3Case1StoreduplicateFile: Failed with unexpected reason"
            );
        }
        Assert.equal(
            r,
            false,
            "suite3Case1StoreduplicateFile did not work as expected"
        );
    }

    // Case 2 - Send Invlaid chunk hash and chunk sizeARR
    function suite3Case2StoreduplicateFile() public {
        uint256[] memory chunksSizeArr = new uint256[](2);
        chunksSizeArr[0] = 10;
        chunksSizeArr[1] = 40;

        string[] memory chunksHashesArr = new string[](1);
        chunksHashesArr[0] = "127125$1821";

        bool r = false;
        try
            fileStorage.storeFile(
                chunksSizeArr,
                Constants.TEST_FILE_1_NAME,
                Constants.TEST_FILE_1_TYPE,
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_FILE_1_ID,
                Constants.TEST_FILE_1_SIZE,
                Constants.TEST_FILE_1_HASH,
                chunksHashesArr
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_INVALID_CHUNKS,
                "suite3Case2StoreduplicateFile: Failed with unexpected reason"
            );
        }
        Assert.equal(
            r,
            false,
            "suite3Case1StoreduplicateFile did not work as expected"
        );
    }
}
