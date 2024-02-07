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
        bytes32 expectedHash = keccak256(abi.encodePacked("test"));
        accessInternalFuncitons.storeFileHashDerived(
            expectedHash,
            "testFileId"
        );

        bytes32 retrievedHash = accessInternalFuncitons.getFileHashDerived(
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
        bytes32 fileHash = keccak256(abi.encodePacked("authenticityTest"));
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
        bytes32 fileHash = keccak256(abi.encodePacked("deleteTest"));
        accessInternalFuncitons.storeFileHashDerived(
            fileHash,
            "deleteTestFileId"
        );

        accessInternalFuncitons.deleteFileHashDerived("deleteTestFileId");

        bytes32 retrievedHash = accessInternalFuncitons.getFileHashDerived(
            "deleteTestFileId"
        );

        Assert.equal(
            retrievedHash,
            bytes32(0),
            "Deleted file hash should be empty"
        );
    }

    // Negative Test case: Validate file authenticity with incorrect hash and correct uniqueId
    function testInvalidateFileAuthenticity() public {
        bytes32 fileHash = keccak256(
            abi.encodePacked("invalidAuthenticityTest")
        );
        accessInternalFuncitons.storeFileHashDerived(
            fileHash,
            "invalidAuthenticityTestFileId"
        );

        bool isValid = accessInternalFuncitons.validateFileAuthenticityDerived(
            bytes32(0), // Incorrect hash
            "invalidAuthenticityTestFileId"
        );

        Assert.equal(
            isValid,
            false,
            "File authenticity should be invalid with incorrect hash and correct uniqueId"
        );
    }
}