// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";
import "../utils/Constants.sol";
import "hardhat/console.sol";

contract FileStorageManager is ChunkManager, NodeManager {
    address internal owner;

    event FileUploaded(
        string fileId,
        string fileName,
        string fileType,
        bytes32 fileHash,
        uint256 fileSize,
        uint256 uploadTime,
        address uploader
    );

    event FileRemoved(address uploader, string fileId);

    struct FileMetadata {
        string fileId;
        string fileName;
        string fileType;
        bytes32 fileHash;
        uint256 fileSize;
        uint256 uploadTime;
        address ownerAddress;
        string fileEncoding;
    }

    struct FileRetrieve {
        FileMetadata file;
        address[] chunkNodeAddresses;
    }

    address[] chunkStorageNodeTempAddress;

    // Mapping from address to FileMetadata
    mapping(address => FileMetadata[]) private addressToFile;
    mapping(address => mapping(string => mapping(uint256 => address[])))
        private nodeAddressOfChunks;

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
        bytes32 _fileHash
    ) public {
        // Iterate through each chunk and distribute them to nodes

        require(allNodes.length != 0, Constants.STORE_FILE_NO_NODES_FOUND);
        require(
            bytes32(getFileHash(_uniqueId)) == bytes32(0),
            Constants.STORE_FILE_DUPLICATE_FILE_ID
        );

        for (uint256 i = 0; i < _chunksSizeArr.length; i++) {
            delete chunkStorageNodeTempAddress;

            uint256 chunkSize = _chunksSizeArr[i];

            uint256 chunkDuplicationCounter = 0;

            uint256 maxDuplicationNum = numMaxChunksDuplication;

            if (allNodes.length < 3) {
                maxDuplicationNum = allNodes.length;
            }

            while (chunkDuplicationCounter < maxDuplicationNum) {
                address selectedNodeAddress = findAvailableNode(
                    chunkSize,
                    chunkStorageNodeTempAddress
                );

                emit logAddress(selectedNodeAddress);

                chunkStorageNodeTempAddress.push(selectedNodeAddress);

                emit logAddress2(selectedNodeAddress);

                chunkDuplicationCounter++;

                // Pass the file ID along with node address and chunk data
                storeChunkInNode(
                    selectedNodeAddress,
                    chunkSize,
                    _uniqueId,
                    i
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

    function retrieveFilesArray()
        internal
        view
        returns (FileMetadata[] memory)
    {
        require(
            msg.sender != address(0),
            Constants.STORE_FILE_METADATA_INVALID_SENDER
        );

        return addressToFile[msg.sender];
    }

    function retrieveFileDetails(string memory _fileId)
        public
        view
        returns (FileRetrieve memory)
    {
        // Return File meta data and chunk node addresses

        FileMetadata[] memory filesArr = retrieveFilesArray();

        for (uint256 i = 0; i < filesArr.length; i++) {
            if (compareStrings(filesArr[i].fileId, _fileId)) {
                require(
                    msg.sender == filesArr[i].ownerAddress,
                    Constants.RETRIEVE_FILE_DETAILS_UNAUTHORIZED_CALLER_ADDRESS
                );
                return
                    FileRetrieve(
                        filesArr[i],
                        retrieveChunkNodeAddresses(_fileId)
                    );
            }
        }

        require(false, Constants.RETRIEVE_FILE_DETAILS_FILE_NOT_FOUND);

        address[] memory dummyAddr;
        FileMetadata memory dummy = FileMetadata(
            "",
            "",
            "",
            bytes32(0),
            0,
            0,
            address(0),
            ""
        );
        return FileRetrieve(dummy, dummyAddr);
    }

    function deleteFile(string memory _fileId) public {
        require(
            addressToFile[msg.sender].length > 0,
            Constants.DELETE_FILE_INVALID_FILE_ID
        );

        FileMetadata[] memory filesArr = addressToFile[msg.sender];

        uint256 lastIndex = filesArr.length - 1;

        FileMetadata memory lastFile = filesArr[lastIndex];

        FileMetadata memory fileToRemove;

        bool isFileFound = false;
        // SWAP last and fileId index
        for (uint256 i = 0; i < filesArr.length; i++) {
            if (compareStrings(filesArr[i].fileId, _fileId)) {
                isFileFound = true;
                fileToRemove = filesArr[i];
                addressToFile[msg.sender][i] = lastFile;
            }
        }

        require(isFileFound, Constants.DELETE_FILE_NOT_FOUND);

        addressToFile[msg.sender][lastIndex] = fileToRemove;

        // Delete last index as its the intended file
        addressToFile[msg.sender].pop();

        // Delete Chunks from node adrresses
        deleteChunkInNode(_fileId);

        // Delete File Hash
        deleteFileHash(_fileId);

        emit FileRemoved(msg.sender, _fileId);
    }

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
