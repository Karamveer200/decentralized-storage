// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";
import "./_UserManager.sol";
import "../utils/Constants.sol";

import "hardhat/console.sol";

contract FileStorageManager {
    NodeManager nodeManager;
    ChunkManager chunkManager;
    UserManager userManager;

    address internal owner;

    constructor(
        address nodeManagerAddress,
        address chunkManagerAddress,
        address payable userManagerAddress
    ) {
        owner = msg.sender;

        nodeManager = NodeManager(nodeManagerAddress);
        chunkManager = ChunkManager(chunkManagerAddress);
        userManager = UserManager(userManagerAddress);
    }

    event FileUploaded(
        string fileId,
        string fileName,
        string fileType,
        string fileHash,
        uint256 fileSize,
        uint256 uploadTime,
        address uploader
    );

    event FileRemoved(address uploader, string fileId);

    struct FileMetadata {
        string fileId;
        string fileName;
        string fileType;
        string fileHash;
        uint256 fileSize;
        uint256 uploadTime;
        address ownerAddress;
        string fileEncoding;
    }

    struct FileRetrieve {
        FileMetadata file;
        address[] chunkNodeAddresses;
        string[] chunkHashesOrder;
    }

    address[] chunkStorageNodeTempAddress;

    mapping(address => FileMetadata[]) internal addressToFile;

    mapping(string => string[]) internal fileIdToChunkHashesOrder;

    mapping(address => mapping(string => mapping(uint256 => address[])))
        private nodeAddressOfChunks;

    uint256[] dummyChunksSizeArr;
    string[] dummyChunksHashesArr;

    function storeFile(
        string memory _fileName,
        string memory _uniqueId,
        address _userAddress,
        uint256 _fileSize
    ) public {
        // Dummy file inputs for simulation
        dummyChunksSizeArr[0] = 10;
        dummyChunksSizeArr[1] = 10;
        dummyChunksSizeArr[2] = 10;

        dummyChunksHashesArr[0] = "hash";
        dummyChunksHashesArr[1] = "hash";
        dummyChunksHashesArr[2] = "hash";

        string memory _fileType = ".txt";
        string memory _fileEncoding = "7-Bit";
        string memory _fileHash = "xRandomHash";

        require(
            nodeManager.getAllNodesLength() != 0,
            Constants.STORE_FILE_NO_NODES_FOUND
        );

        require(
            dummyChunksHashesArr.length == dummyChunksSizeArr.length,
            Constants.STORE_FILE_INVALID_CHUNKS
        );

        require(
            _fileSize + userManager.getUserStorageUsed(_userAddress) <=
                userManager.getUserStorageallocated(_userAddress),
            "User storage limit exceeded."
        );

        if (
            userManager.getUserTier(_userAddress) ==
            userManager.getAdvancedTier()
        ) {
            require(
                _fileSize + userManager.getUserStorageUsed(_userAddress) <=
                    userManager.getUserStorageallocated(_userAddress),
                "Advanced user storage limit exceeded."
            );
        } else {
            // Free tier
            require(
                _fileSize + userManager.getUserStorageUsed(_userAddress) <=
                    userManager.GBToBytes(userManager.getFreeStorageAmount()),
                "Free user storage limit exceeded."
            );
        }

        for (uint256 i = 0; i < dummyChunksSizeArr.length; i++) {
            delete chunkStorageNodeTempAddress;

            string memory chunkHash = dummyChunksHashesArr[i];

            uint256 chunkSize = dummyChunksSizeArr[i];

            uint256 chunkDuplicationCounter = 0;

            uint256 maxDuplicationNum = chunkManager.getChunkDuplicateCount();

            fileIdToChunkHashesOrder[_uniqueId].push(chunkHash);

            if (nodeManager.getAllNodesLength() < 3) {
                maxDuplicationNum = nodeManager.getAllNodesLength();
            }

            while (chunkDuplicationCounter < maxDuplicationNum) {
                address selectedNodeAddress = nodeManager.findAvailableNode(
                    chunkSize,
                    chunkStorageNodeTempAddress
                );

                if (
                    chunkStorageNodeTempAddress.length ==
                    nodeManager.getAllNodesLength()
                ) {
                    break;
                }

                if (selectedNodeAddress == address(0)) {
                    continue;
                }

                chunkStorageNodeTempAddress.push(selectedNodeAddress);

                chunkDuplicationCounter++;

                // Pass the file ID along with node address and chunk data
                nodeManager.storeChunkInNode(
                    selectedNodeAddress,
                    chunkSize,
                    _uniqueId,
                    chunkHash
                );
            }
        }

        delete chunkStorageNodeTempAddress;

        chunkManager.storeFileHash(_fileHash, _uniqueId);

        storeFileMetadata(
            _fileName,
            _fileType,
            _fileHash,
            _fileEncoding,
            _uniqueId,
            _fileSize,
            _userAddress
        );

        userManager.addUserAddresses(_userAddress);
    }

    function storeFileMetadata(
        string memory _fileName,
        string memory _fileType,
        string memory _fileHash,
        string memory _fileEncoding,
        string memory _uniqueId,
        uint256 _fileSize,
        address _userAddress
    ) internal {
        require(
            _userAddress != address(0),
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
            bytes(_fileHash).length > 0,
            Constants.STORE_FILE_METADATA_INVALID_FILE_HASH
        );
        require(_fileSize > 0, Constants.STORE_FILE_METADATA_INVALID_FILE_SIZE);
        require(
            bytes(_uniqueId).length > 0,
            Constants.STORE_FILE_METADATA_INVALID_FILE_ID
        );

        uint256 timeStamp = block.timestamp;

        addressToFile[_userAddress].push(
            FileMetadata(
                _uniqueId,
                _fileName,
                _fileType,
                _fileHash,
                _fileSize,
                timeStamp,
                _userAddress,
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
            _userAddress
        );
    }

    function retrieveFilesArray(address _userAddress)
        internal
        view
        returns (FileMetadata[] memory)
    {
        require(
            _userAddress != address(0),
            Constants.STORE_FILE_METADATA_INVALID_SENDER
        );

        return addressToFile[_userAddress];
    }

    function retrieveFile(string memory _fileId, address _userAddress)
        public
        returns (FileRetrieve memory)
    {
        require(
            _userAddress != address(0),
            Constants.STORE_FILE_METADATA_INVALID_SENDER
        );

        FileMetadata[] memory filesArr = retrieveFilesArray(_userAddress);

        for (uint256 i = 0; i < filesArr.length; i++) {
            if (chunkManager.areStringsEqual(filesArr[i].fileId, _fileId)) {
                require(
                    _userAddress == filesArr[i].ownerAddress,
                    Constants.RETRIEVE_FILE_DETAILS_UNAUTHORIZED_CALLER_ADDRESS
                );
                return
                    FileRetrieve(
                        filesArr[i],
                        nodeManager.retrieveChunkNodeAddresses(_fileId),
                        fileIdToChunkHashesOrder[_fileId]
                    );
            }
        }

        require(false, Constants.RETRIEVE_FILE_DETAILS_FILE_NOT_FOUND);

        address[] memory dummyAddr;
        FileMetadata memory dummy = FileMetadata(
            "",
            "",
            "",
            "",
            0,
            0,
            address(0),
            ""
        );

        return
            FileRetrieve(dummy, dummyAddr, fileIdToChunkHashesOrder[_fileId]);
    }

    function deleteFile(string memory _fileId, address _userAddress) public {
        require(
            addressToFile[_userAddress].length > 0,
            Constants.DELETE_FILE_INVALID_FILE_ID
        );

        FileMetadata[] memory filesArr = addressToFile[_userAddress];

        uint256 lastIndex = filesArr.length - 1;

        FileMetadata memory lastFile = filesArr[lastIndex];

        FileMetadata memory fileToRemove;

        bool isFileFound = false;
        // SWAP last and fileId index
        for (uint256 i = 0; i < filesArr.length; i++) {
            if (chunkManager.areStringsEqual(filesArr[i].fileId, _fileId)) {
                isFileFound = true;
                fileToRemove = filesArr[i];
                addressToFile[_userAddress][i] = lastFile;
            }
        }

        require(isFileFound, Constants.DELETE_FILE_NOT_FOUND);

        addressToFile[_userAddress][lastIndex] = fileToRemove;

        // Delete last index as its the intended file
        addressToFile[_userAddress].pop();

        // Delete Chunks from node adrresses
        nodeManager.deleteChunkInNode(_fileId);

        // Delete File Hash
        chunkManager.deleteFileHash(_fileId);

        emit FileRemoved(_userAddress, _fileId);
    }
}
