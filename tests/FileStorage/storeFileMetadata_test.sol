// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";
import "../../contracts/_FileStorage.sol";
import "../../utils/Constants.sol";
import "../_AccessInternalFunctions.sol";
import "hardhat/console.sol";

// NEGATIVE SUITE
contract StoreFileMetaDataTestSuite1 {
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        accessInternalFuncitons = new AccessInternalFunctions();
    }

    // Case 1 - Expected to go to catch block as filename is empty
    function suite1Case1StoreFileMetaData() public {
          uint256[] memory chunksSizeArr = new uint256[](4);
        chunksSizeArr[0] = 10;
        chunksSizeArr[1] = 20;
        chunksSizeArr[2] = 30;
        chunksSizeArr[3] = 40;

        bytes32 getFileHash = accessInternalFuncitons.createHashDerived(
            chunksArr
        );

        bool r = false;
        try
            accessInternalFuncitons.storeFileMetadataDerived(
                Constants.TEST_EMPTY_STRING,
                Constants.TEST_FILE_1_TYPE,
                getFileHash,
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_FILE_1_ID,
                Constants.TEST_FILE_1_SIZE
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_METADATA_INVALID_FILE_NAME,
                "suite1Case1StoreFile: Failed with unexpected reason"
            );
        }
        Assert.equal(r, false, "suite1Case1StoreFile did not work as expected");
    }

    // Case 2 - Expected to go to catch block as filetype is empty
    function suite1Case2StoreFileMetaData() public {
          uint256[] memory chunksSizeArr = new uint256[](4);
        chunksSizeArr[0] = 10;
        chunksSizeArr[1] = 20;
        chunksSizeArr[2] = 30;
        chunksSizeArr[3] = 40;

        bytes32 getFileHash = accessInternalFuncitons.createHashDerived(
            chunksArr
        );

        bool r = false;
        try
            accessInternalFuncitons.storeFileMetadataDerived(
                Constants.TEST_FILE_1_NAME,
                Constants.TEST_EMPTY_STRING,
                getFileHash,
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_FILE_1_ID,
                Constants.TEST_FILE_1_SIZE
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_METADATA_INVALID_FILE_TYPE,
                "suite1Case2StoreFileMetaData: Failed with unexpected reason"
            );
        }
        Assert.equal(
            r,
            false,
            "suite1Case2StoreFileMetaData did not work as expected"
        );
    }
}

// NEGATIVE SUITE
contract StoreFileMetaDataTestSuite2 {
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        accessInternalFuncitons = new AccessInternalFunctions();
    }

    // Case 1 - Expected to go to catch block as filehash is empty
    function suite2Case1StoreFileMetaData() public {
        bool r = false;
        try
            accessInternalFuncitons.storeFileMetadataDerived(
                Constants.TEST_FILE_1_NAME,
                Constants.TEST_FILE_1_TYPE,
                bytes32(0),
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_FILE_1_ID,
                Constants.TEST_FILE_1_SIZE
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_METADATA_INVALID_FILE_HASH,
                "suite2Case1StoreFileMetaData: Failed with unexpected reason"
            );
        }
        Assert.equal(
            r,
            false,
            "suite2Case1StoreFileMetaData did not work as expected"
        );
    }

    // Case 2 - Expected to go to catch block as _uniqueId is empty
    function suite2Case2StoreFileMetaData() public {
          uint256[] memory chunksSizeArr = new uint256[](4);
        chunksSizeArr[0] = 10;
        chunksSizeArr[1] = 20;
        chunksSizeArr[2] = 30;
        chunksSizeArr[3] = 40;

        bytes32 getFileHash = accessInternalFuncitons.createHashDerived(
            chunksArr
        );

        bool r = false;
        try
            accessInternalFuncitons.storeFileMetadataDerived(
                Constants.TEST_FILE_1_NAME,
                Constants.TEST_FILE_1_TYPE,
                getFileHash,
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_EMPTY_STRING,
                Constants.TEST_FILE_1_SIZE
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_METADATA_INVALID_FILE_ID,
                "suite2Case2StoreFileMetaData: Failed with unexpected reason"
            );
        }
        Assert.equal(
            r,
            false,
            "suite2Case2StoreFileMetaData did not work as expected"
        );
    }
}

// NEGATIVE AND POSITIVE SUITE
contract StoreFileMetaDataTestSuite3 {
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        accessInternalFuncitons = new AccessInternalFunctions();
    }

    // Case 1 - Expected to go to catch block as _fileSize is empty
    function suite3Case1StoreFileMetaData() public {
          uint256[] memory chunksSizeArr = new uint256[](4);
        chunksSizeArr[0] = 10;
        chunksSizeArr[1] = 20;
        chunksSizeArr[2] = 30;
        chunksSizeArr[3] = 40;

        bytes32 getFileHash = accessInternalFuncitons.createHashDerived(
            chunksArr
        );

        bool r = false;
        try
            accessInternalFuncitons.storeFileMetadataDerived(
                Constants.TEST_FILE_1_NAME,
                Constants.TEST_FILE_1_TYPE,
                getFileHash,
                Constants.TEST_FILE_1_ENCODING,
                Constants.TEST_FILE_1_ID,
                Constants.TEST_ZERO_SIZE
            )
        {
            r = true;
        } catch Error(string memory reason) {
            Assert.equal(
                reason,
                Constants.STORE_FILE_METADATA_INVALID_FILE_SIZE,
                "suite3Case1StoreFileMetaData: Failed with unexpected reason"
            );
        }
        Assert.equal(
            r,
            false,
            "suite3Case1StoreFileMetaData did not work as expected"
        );
    }

    // Case 2 - Expected to store File Meta data
    function suite3Case2StoreFileMetaData() public {
          uint256[] memory chunksSizeArr = new uint256[](4);
        chunksSizeArr[0] = 10;
        chunksSizeArr[1] = 20;
        chunksSizeArr[2] = 30;
        chunksSizeArr[3] = 40;

        bytes32 getFileHash = accessInternalFuncitons.createHashDerived(
            chunksArr
        );

        accessInternalFuncitons.storeFileMetadataDerived(
            Constants.TEST_FILE_1_NAME,
            Constants.TEST_FILE_1_TYPE,
            getFileHash,
            Constants.TEST_FILE_1_ENCODING,
            Constants.TEST_FILE_1_ID,
            Constants.TEST_FILE_1_SIZE
        );

        AccessInternalFunctions.FileMetadata[]
            memory filesArr = accessInternalFuncitons
                .retrieveFilesArrayDervied();

        Assert.equal(
            filesArr[0].fileId,
            Constants.TEST_FILE_1_ID,
            "suite3Case2StoreFileMetaData did not work as expected"
        );
    }
}