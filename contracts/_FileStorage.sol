// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";

contract FileStorageManager is ChunkManager, NodeManager {
    address public owner;

    event FileUploaded(
        uint256 fileId,
        string fileName,
        string fileType,
        string fileHash,
        uint256 fileSize,
        uint256 uploadTime,
        address uploader
    );
    
    event FileRemoved(
        address uploader,
        uint256 fileId
    );

    struct FileMetadata {
        uint256 fileId;
        string fileName;
        string fileType;
        string fileHash;
        uint256 fileSize;
        uint256 uploadTime;
        address ownerAddress;
    }

    // Mapping from address to FileMetadata
    mapping(address => FileMetadata[]) private addressToFile;

    uint256 public fileIdCount = 0;

    constructor() NodeManager() {
        owner = msg.sender;
    }

    function storeFile(
        string memory _fileName,
        string memory _fileType,
        string memory _fileHash,
        uint256 _fileSize
    ) public {
        require(msg.sender != address(0));
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(bytes(_fileHash).length > 0);
        require(_fileSize > 0);

        fileIdCount++;

        addressToFile[msg.sender].push(
            FileMetadata(
                fileIdCount,
                _fileName,
                _fileType,
                _fileHash,
                _fileSize,
                block.timestamp,
                msg.sender
            )
        );

        emit FileUploaded(
            fileIdCount,
            _fileName,
            _fileType,
            _fileHash,
            _fileSize,
            block.timestamp,
            msg.sender
        );
    }

    function retrieveFile(uint256 _fileId)
        public
        view
        returns (string memory)
    {
        require(
            addressToFile[msg.sender][_fileId].ownerAddress == msg.sender,
            "Unauthenticated or file not found"
        );
        
        // Return file hash
        return addressToFile[msg.sender][_fileId].fileHash; 
    }

    function deleteFile(uint256 _fileId) public {
        require(
            _fileId >= 0 && _fileId < addressToFile[msg.sender].length,
            "Invalid file id"
        );

        uint256 lastIndex = addressToFile[msg.sender].length - 1;

        if (_fileId != lastIndex) {
            FileMetadata storage lastFile = addressToFile[msg.sender][lastIndex];
            FileMetadata storage fileToRemove = addressToFile[msg.sender][_fileId];

            // SWAP last and fileId index
            addressToFile[msg.sender][_fileId] = lastFile;
            addressToFile[msg.sender][lastIndex] = fileToRemove;
        }

        // Delete last index as its the intended file
        addressToFile[msg.sender].pop();

        fileIdCount--;

        emit FileRemoved(msg.sender, _fileId);
    }
}
