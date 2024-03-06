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

    function retrieveFilesArrayDervied()
        public
        view
        returns (FileMetadata[] memory)
    {
        return retrieveFilesArray();
    }

    //NodeManager Functions
    function getNodeByAddressDerived(address _nodeAddress)
        public
        view
        returns (NodeManager.Node memory)
    {
        return getNodeByAddress(_nodeAddress);
    }

    function getAllNodesDerived() public view returns (address[] memory) {
        return getAllNodes();
    }

    function storeChunkInNodeDerived(
        address _nodeAddress,
        uint256 _chunkSize,
        string memory _fileId,
        string memory _chunkHash
    ) public {
        storeChunkInNode(_nodeAddress, _chunkSize, _fileId, _chunkHash);
    }

    function updateAvailableStorageDerived(
        address _nodeAddress,
        uint256 _newStorage
    ) public {
        updateAvailableStorage(_nodeAddress, _newStorage);
    }

    function addNodeDerived(address _nodeAddress, uint256 _initialStorage)
        public
    {
        addNode(_nodeAddress, _initialStorage);
    }

    function retrieveChunkNodeAddressesDerived(string memory _fileId)
        public
        view
        returns (address[] memory)
    {
        return retrieveChunkNodeAddresses(_fileId);
    }

    //ChunkManager Functions
    function storeFileHashDerived(bytes32 _fileHash, string memory _fileId)
        public
    {
        storeFileHash(_fileHash, _fileId);
    }

    function getFileHashDerived(string memory _fileId)
        public
        view
        returns (bytes32)
    {
        return getFileHash(_fileId);
    }

    function deleteFileHashDerived(string memory _fileId) public {
        deleteFileHash(_fileId);
    }

    function validateFileAuthenticityDerived(
        bytes32 _fileHash,
        string memory _uniqueId
    ) public view returns (bool) {
        return validateFileAuthenticity(_fileHash, _uniqueId);
    }
}
