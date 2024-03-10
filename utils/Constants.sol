// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Constants {
    string public constant STORE_FILE_NO_NODES_FOUND =
        "storeFile: No available nodes found";

    string public constant STORE_FILE_INVALID_CHUNKS =
        "storeFile: Invalid chunks";

    string public constant STORE_FILE_DUPLICATE_FILE_ID =
        "storeFile: Duplicate File Id";

    string public constant STORE_FILE_METADATA_INVALID_SENDER =
        "storeFileMetadata: Invalid sender";

    string public constant STORE_FILE_METADATA_INVALID_FILE_TYPE =
        "storeFileMetadata: Invalid _fileType";

    string public constant STORE_FILE_METADATA_INVALID_FILE_NAME =
        "storeFileMetadata: Invalid _fileName";

    string public constant STORE_FILE_METADATA_INVALID_FILE_HASH =
        "storeFileMetadata: Invalid _fileHash";

    string public constant STORE_FILE_METADATA_INVALID_FILE_SIZE =
        "storeFileMetadata: Invalid _fileSize";

    string public constant STORE_FILE_METADATA_INVALID_FILE_ID =
        "storeFileMetadata: Invalid _uniqueId";

    string public constant RETRIEVE_FILE_DETAILS_FILE_NOT_FOUND =
        "retrieveFileDetails: File Not Found";

    string public constant RETRIEVE_FILE_DETAILS_UNAUTHORIZED_CALLER_ADDRESS =
        "retrieveFileDetails: Unauthorized caller address";

    string public constant DELETE_FILE_INVALID_FILE_ID =
        "deleteFile: Invalid file id";

    string public constant DELETE_FILE_NOT_FOUND = "deleteFile: File Not found";

    // TESTS CONSTANTS
    address public constant TEST_RANDOM_ADDRESS_1 =
        0x38A2E968077a7a13B8D7326c35c921da0000847e;
    address public constant TEST_RANDOM_ADDRESS_2 =
        0x3E57a0F582DB4D97B5E3a0A7F95A731DE9cb7339;
    address public constant TEST_RANDOM_ADDRESS_3 =
        0x2F8a81F66Ad6e19a063e11F006b2726d1D25A5CF;

    uint256 public constant TEST_RANDOM_NODE_SIZE_10000 = 10000;
    uint256 public constant TEST_RANDOM_NODE_SIZE_5000 = 5000;
    string public constant TEST_FILE_1_NAME = "demo_test.txt";
    string public constant TEST_FILE_1_TYPE = ".txt";
    string public constant TEST_FILE_1_ENCODING = "7Bit";
    string public constant TEST_FILE_1_ID = "ui12f-2jf7d-ajd0asd";
    uint256 public constant TEST_FILE_1_SIZE = 200;
    string public constant TEST_FILE_1_HASH = "120182$2fs83389fkdjd";

    string public constant TEST_EMPTY_STRING = "";
    uint256 public constant TEST_ZERO_SIZE = 0;
}
