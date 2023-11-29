// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FileHashRegistry {

    struct FileRecord {
        string hash; // Hash of the file
        address uploader; // Address of the user who uploaded the file
    }

    // Mapping from file hash to FileRecord
    mapping(string => FileRecord) public fileRecords;

    // Event emitted when a file hash is registered
    event FileHashRegistered(string hash, address uploader);

    // Register a file hash
    function registerFileHash(string memory _hash) public {
        require(bytes(fileRecords[_hash].hash).length == 0, "File hash already registered.");

        fileRecords[_hash] = FileRecord({
            hash: _hash,
            uploader: msg.sender
        });

        emit FileHashRegistered(_hash, msg.sender);
    }

    // Retrieve file record by hash
    function getFileRecord(string memory _hash) public view returns (FileRecord memory) {
        require(bytes(fileRecords[_hash].hash).length != 0, "File hash not registered.");
        return fileRecords[_hash];
    }
}
