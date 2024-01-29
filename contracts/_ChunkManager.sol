// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ChunkManager {
    uint256 public numMaxChunksDuplication = 3;
    uint256 public maxChunkSize = 100;

    // Mapping from fileId to fileHash
    mapping(string => bytes32) private fileIdToHash;

    function getFileHash(string memory _fileId)
        internal
        view
        returns (bytes32)
    {
        require(bytes(_fileId).length > 0, "getFileHash: Invalid _fileId");

        return fileIdToHash[_fileId];
    }

    function storeFileHash(bytes32 _fileHash, string memory _fileId) public {
        require(msg.sender != address(0), "storeFileHash: Invalid sender");
        require(
            bytes32(_fileHash) != bytes32(0),
            "storeFileHash: Invalid _fileHash"
        );
        require(bytes(_fileId).length > 0, "storeFileHash: Invalid _fileId");

        fileIdToHash[_fileId] = _fileHash;
    }

    function deleteFileHash(string memory _fileId) public {
        require(bytes(_fileId).length > 0, "deleteFileHash: Invalid _fileId");
        require(
            bytes32(fileIdToHash[_fileId]) != bytes32(0),
            "deleteFileHash: Invalid fileIdToHash"
        );

        delete fileIdToHash[_fileId];
    }

    function validateFileAuthenticity(
        bytes32 _fileHash,
        string memory _uniqueId
    ) internal view returns (bool) {
        return _fileHash == fileIdToHash[_uniqueId];
    }

    function createHash(string[] memory stringArray)
        public
        pure
        returns (bytes32)
    {
        bytes memory toBeHashed = "";

        for (uint256 i = 0; i < stringArray.length; i++) {
            toBeHashed = abi.encodePacked(toBeHashed, stringArray[i]);
        }

        return keccak256(toBeHashed);
    }
}
