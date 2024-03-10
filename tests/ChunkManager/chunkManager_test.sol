// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol";
import "../../contracts/_FileStorage.sol";
import "../_AccessInternalFunctions.sol";
import "../../utils/Constants.sol";

contract PositiveChunkManagerTest {
    ChunkManager chunkManager;
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        chunkManager = new ChunkManager();
        accessInternalFuncitons = new AccessInternalFunctions();
    }

    //Positive Test case: Store file hash and retrieve it
    function testStoreFileHashAndRetrieve() public {
        string memory expectedHash = "testFileId";
        accessInternalFuncitons.storeFileHashDerived(
            expectedHash,
            "testFileId"
        );

        string memory  retrievedHash = accessInternalFuncitons.getFileHashDerived(
            "testFileId"
        );

        Assert.equal(
            retrievedHash,
            expectedHash,
            "Stored and retrieved hashes should match"
        );
    }

    //Positive Test case: Validate file authenticity with correct hash and uniqueId
    function testValidateFileAuthenticity() public {
        string memory fileHash = "authenticityTestFileId";
        accessInternalFuncitons.storeFileHashDerived(
            fileHash,
            "authenticityTestFileId"
        );

        bool isValid = accessInternalFuncitons.validateFileAuthenticityDerived(
            fileHash,
            "authenticityTestFileId"
        );

        Assert.equal(
            isValid,
            true,
            "File authenticity should be valid with correct hash and uniqueId"
        );
    }
}


contract NegativeChunkManagerTest {
    ChunkManager chunkManager;
    AccessInternalFunctions accessInternalFuncitons;

    function beforeAll() public {
        chunkManager = new ChunkManager();
        accessInternalFuncitons = new AccessInternalFunctions();
    }

        //Negative Test case: Delete file hash and attempt to retrieve it
    function testDeleteFileHash() public {
        string memory fileHash = "deleteTest";
        accessInternalFuncitons.storeFileHashDerived(
            fileHash,
            "deleteTestFileId"
        );

        accessInternalFuncitons.deleteFileHashDerived("deleteTestFileId");

         string memory retrievedHash = accessInternalFuncitons.getFileHashDerived(
            "deleteTestFileId"
        );

        Assert.equal(
            retrievedHash,
            "",
            "Deleted file hash should be empty"
        );
    }

    // Negative Test case: Validate file authenticity with incorrect hash and correct uniqueId
    function testInvalidateFileAuthenticity() public {
        string memory fileHash = "invalidAuthenticityTest";

        accessInternalFuncitons.storeFileHashDerived(
            fileHash,
            "invalidAuthenticityTestFileId"
        );

        bool isValid = accessInternalFuncitons.validateFileAuthenticityDerived(
            "", // Incorrect hash
            "invalidAuthenticityTestFileId"
        );

        Assert.equal(
            isValid,
            false,
            "File authenticity should be invalid with incorrect hash and correct uniqueId"
        );
    }
}