// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ChunkManager {
    uint256 internal  numMaxChunksDuplication = 3;

    // Mapping from fileId to fileHash
    mapping(string => string) internal fileIdToHash;

    function getFileHash(string memory _fileId)
        public
        view
        returns (string memory)
    {
        require(bytes(_fileId).length > 0, "getFileHash: Invalid _fileId");

        return fileIdToHash[_fileId];
    }

    function storeFileHash(string memory _fileHash, string memory _fileId)
        public
    {
        require(msg.sender != address(0), "storeFileHash: Invalid sender");
        require(
            bytes(_fileHash).length > 0,
            "storeFileHash: Invalid _fileHash"
        );
        require(bytes(_fileId).length > 0, "storeFileHash: Invalid _fileId");

        fileIdToHash[_fileId] = _fileHash;
    }

    function deleteFileHash(string memory _fileId) public {
        require(bytes(_fileId).length > 0, "deleteFileHash: Invalid _fileId");
        require(
            bytes(fileIdToHash[_fileId]).length > 0,
            "deleteFileHash: Invalid fileIdToHash"
        );

        delete fileIdToHash[_fileId];
    }

    function validateFileAuthenticity(
        string memory _fileHash,
        string memory _uniqueId
    ) public view returns (bool) {
        return areStringsEqual(_fileHash, fileIdToHash[_uniqueId]);
    }

    function areStringsEqual(string memory string1, string memory string2)
        public
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(string1)) ==
            keccak256(abi.encodePacked(string2));
    }

    function getChunkDuplicateCount() public view returns(uint256){
        return numMaxChunksDuplication;
    }
}
