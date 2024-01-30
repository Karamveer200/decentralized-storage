// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

import "../contracts/_FileStorage.sol";

contract AccessInternalFunctions is FileStorageManager {
    function storeFileMetadataDerived(
        string memory _fileName,
        string memory _fileType,
        bytes32 _fileHash,
        string memory _fileEncoding,
        string memory _uniqueId,
        uint256 _fileSize
    ) public {
        return
            storeFileMetadata(
                _fileName,
                _fileType,
                _fileHash,
                _fileEncoding,
                _uniqueId,
                _fileSize
            );
    }

    function createHashDerived(string[] memory stringArray)
        public
        pure
        returns (bytes32)
    {
        return createHash(stringArray);
    }

    function retrieveFilesArrayDervied() public view returns (FileMetadata[] memory){
        return retrieveFilesArray();
    }
}
