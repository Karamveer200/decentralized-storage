// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ChunkManager {
    uint256 public numMaxChunksDuplication = 3;
    uint256 public maxChunkSize = 100;

    // Mapping from fileId to fileHash
    mapping(uint256 => bytes32) private fileIdToHash;

    function storeFileHash(bytes32 _fileHash, uint256 _uniqueId) public {
        require(msg.sender != address(0));
        require(bytes32(_fileHash).length > 0);
        require(_uniqueId > 0);

        fileIdToHash[_uniqueId] = _fileHash;
    }

    function validateFileAuthenticity(bytes32 _fileHash, uint256 _uniqueId) internal view returns (bool) {
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
