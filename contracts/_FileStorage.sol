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
        bytes32 fileHash,
        uint256 fileSize,
        uint256 uploadTime,
        address uploader
    );

    event FileRemoved(address uploader, uint256 fileId);

    struct FileMetadata {
        uint256 fileId;
        string fileName;
        string fileType;
        bytes32 fileHash;
        uint256 fileSize;
        uint256 uploadTime;
        address ownerAddress;
        string fileEncoding;
        address[] fileStorageNodeAddress;
    }

    // Mapping from address to FileMetadata
    mapping(address => FileMetadata[]) private addressToFile;
    address[] nodeAddressOfChunks;

    constructor() NodeManager() {
        owner = msg.sender;
    }

    function storeFile (
        string[] memory _chunksArr,
        string memory _fileName,
        string memory _fileType,
        string memory _fileEncoding,
        uint256 _uniqueId,
        uint256 _fileSize
    ) public returns (address[] memory) {
        
        // Iterate through each chunk and distribute them to nodes
        for (uint256 i = 0; i < _chunksArr.length; i++) {
            uint256 chunkSize = bytes(_chunksArr[i]).length;

            uint256 chunkDuplicationCounter = 0;
            uint256 maxDuplicationNum = numMaxChunksDuplication;

            if (allNodes.length < 3) {
                maxDuplicationNum = allNodes.length;
            }

            while (chunkDuplicationCounter < maxDuplicationNum) {
                chunkDuplicationCounter++;
                address selectedNodeAddress = findAvailableNode(chunkSize);
                require(
                    selectedNodeAddress != address(0),
                    "No available nodes"
                );

                if (
                    !isAddressPresent(selectedNodeAddress, nodeAddressOfChunks)
                ) {
                    nodeAddressOfChunks.push(selectedNodeAddress);
                }

                storeChunkInNode(selectedNodeAddress, _chunksArr[i]);

                // Update available storage of the current node
                updateAvailableStorage(
                    selectedNodeAddress,
                    nodes[selectedNodeAddress].availableStorage - chunkSize
                );
            }
        }

        bytes32 getFileHash = createHash(_chunksArr);

        storeFileHash(getFileHash, _uniqueId);

        storeFileMetadata(
            _fileName,
            _fileType,
            getFileHash,
            _fileEncoding,
            nodeAddressOfChunks,
            _uniqueId,
            _fileSize
        );

        return nodeAddressOfChunks;
    }

    function storeFileMetadata(
        string memory _fileName,
        string memory _fileType,
        bytes32 _fileHash,
        string memory _fileEncoding,
        address[] memory _fileStorageNodeAddress,
        uint256 _uniqueId,
        uint256 _fileSize
    ) public {
        require(msg.sender != address(0));
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(bytes32(_fileHash).length > 0);
        require(_fileStorageNodeAddress.length > 0);
        require(_fileSize > 0);
        require(_uniqueId > 0);

        delete nodeAddressOfChunks;

        addressToFile[msg.sender].push(
            FileMetadata(
                _uniqueId,
                _fileName,
                _fileType,
                _fileHash,
                _fileSize,
                block.timestamp,
                msg.sender,
                _fileEncoding,
                _fileStorageNodeAddress
            )
        );

        emit FileUploaded(
            _uniqueId,
            _fileName,
            _fileType,
            _fileHash,
            _fileSize,
            block.timestamp,
            msg.sender
        );
    }

    function retrieveFile(uint256 _fileId) public view returns (bytes32) {
        require(
            addressToFile[msg.sender][_fileId].ownerAddress == msg.sender,
            "Unauthenticated or file not found"
        );

        // Return file hash
        return addressToFile[msg.sender][_fileId].fileHash;
    }

    function deleteFile(uint256 _fileId) public {
        require(
            _fileId >= 0 && addressToFile[msg.sender].length > 0,
            "Invalid file id"
        );

        FileMetadata[] storage filesArr = addressToFile[msg.sender];

        uint256 lastIndex = filesArr.length - 1;

        if (_fileId != lastIndex) {
            FileMetadata storage lastFile = filesArr[lastIndex];

            FileMetadata memory fileToRemove;

            for (uint256 i = 0; i < filesArr.length; i++) {
                if (filesArr[i].fileId == _fileId) {
                    fileToRemove = filesArr[i];
                }
            }

            // SWAP last and fileId index
            addressToFile[msg.sender][_fileId] = lastFile;
            addressToFile[msg.sender][lastIndex] = fileToRemove;
        }

        // Delete last index as its the intended file
        addressToFile[msg.sender].pop();

        emit FileRemoved(msg.sender, _fileId);
    }

    function isAddressPresent(
        address nodeAddress,
        address[] memory fileStorageNodeAddresses
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < fileStorageNodeAddresses.length; i++) {
            if (fileStorageNodeAddresses[i] == nodeAddress) {
                return true;
            }
        }
        return false;
    }
}
