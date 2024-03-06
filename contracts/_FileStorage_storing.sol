// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_FileStorage.sol";
import "../utils/Constants.sol";
import "hardhat/console.sol";

contract FileStorageManagerStoring is FileStorageManager {
    address internal owner;

    constructor() NodeManager() {
        owner = msg.sender;
    }

    function storeFile(
        uint256[] memory _chunksSizeArr,
        string memory _fileName,
        string memory _fileType,
        string memory _fileEncoding,
        string memory _uniqueId,
        uint256 _fileSize,
        bytes32 _fileHash,
        string[] memory _chunkHashes
    ) public {
        // Iterate through each chunk and distribute them to nodes

        require(allNodes.length != 0, Constants.STORE_FILE_NO_NODES_FOUND);
        require(
            _chunkHashes.length == _chunksSizeArr.length,
            Constants.STORE_FILE_INVALID_CHUNKS
        );
        require(
            bytes32(getFileHash(_uniqueId)) == bytes32(0),
            Constants.STORE_FILE_DUPLICATE_FILE_ID
        );
        require(
            _fileSize + users[msg.sender].storageUsed <=
                users[msg.sender].storageAllocated,
            "User storage limit exceeded."
        );

        // Check storage limit based on the user's tier
        if (users[msg.sender].tier == Tier.PayAsYouGo) {
            require(
                _fileSize + users[msg.sender].storageUsed <=
                    getNodeAvailableStorage(msg.sender),
                "Insufficient available storage for PayAsYouGo user."
            );
        } else if (users[msg.sender].tier == Tier.Advanced) {
            require(
                _fileSize + users[msg.sender].storageUsed <=
                    users[msg.sender].storageAllocated,
                "Advanced user storage limit exceeded."
            );
        } else {
            // Free tier
            require(
                _fileSize + users[msg.sender].storageUsed <=
                    GBToBytes(freeStorage),
                "Free user storage limit exceeded."
            );
        }

        for (uint256 i = 0; i < _chunksSizeArr.length; i++) {
            delete chunkStorageNodeTempAddress;

            string memory chunkHash = _chunkHashes[i];

            uint256 chunkSize = _chunksSizeArr[i];

            uint256 chunkDuplicationCounter = 0;

            uint256 maxDuplicationNum = numMaxChunksDuplication;

            fileIdToChunkHashesOrder[_uniqueId].push(chunkHash);

            if (allNodes.length < 3) {
                maxDuplicationNum = allNodes.length;
            }

            while (chunkDuplicationCounter < maxDuplicationNum) {
                address selectedNodeAddress = findAvailableNode(
                    chunkSize,
                    chunkStorageNodeTempAddress
                );

                chunkStorageNodeTempAddress.push(selectedNodeAddress);

                chunkDuplicationCounter++;

                // Pass the file ID along with node address and chunk data
                storeChunkInNode(
                    selectedNodeAddress,
                    chunkSize,
                    _uniqueId,
                    chunkHash
                );
            }
        }

        delete chunkStorageNodeTempAddress;

        storeFileHash(_fileHash, _uniqueId);

        storeFileMetadata(
            _fileName,
            _fileType,
            _fileHash,
            _fileEncoding,
            _uniqueId,
            _fileSize
        );

        addAddress(msg.sender);
    }

    function storeFileMetadata(
        string memory _fileName,
        string memory _fileType,
        bytes32 _fileHash,
        string memory _fileEncoding,
        string memory _uniqueId,
        uint256 _fileSize
    ) internal {
        require(
            msg.sender != address(0),
            Constants.STORE_FILE_METADATA_INVALID_SENDER
        );
        require(
            bytes(_fileType).length > 0,
            Constants.STORE_FILE_METADATA_INVALID_FILE_TYPE
        );
        require(
            bytes(_fileName).length > 0,
            Constants.STORE_FILE_METADATA_INVALID_FILE_NAME
        );
        require(
            bytes32(_fileHash) != bytes32(0),
            Constants.STORE_FILE_METADATA_INVALID_FILE_HASH
        );
        require(_fileSize > 0, Constants.STORE_FILE_METADATA_INVALID_FILE_SIZE);
        require(
            bytes(_uniqueId).length > 0,
            Constants.STORE_FILE_METADATA_INVALID_FILE_ID
        );

        uint256 timeStamp = block.timestamp;

        addressToFile[msg.sender].push(
            FileMetadata(
                _uniqueId,
                _fileName,
                _fileType,
                _fileHash,
                _fileSize,
                timeStamp,
                msg.sender,
                _fileEncoding
            )
        );

        emit FileUploaded(
            _uniqueId,
            _fileName,
            _fileType,
            _fileHash,
            _fileSize,
            timeStamp,
            msg.sender
        );
    }
}
