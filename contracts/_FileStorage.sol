// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";
import "./_UserManager.sol";
import "../utils/Constants.sol";
import "./_UserManager.sol";

import "hardhat/console.sol";

contract FileStorageManager is ChunkManager, NodeManager, UserManager {
    address internal owner;

    constructor() {
        owner = msg.sender;
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

    mapping(address => FileMetadata[]) public addressToFile;

    mapping(string => string[]) public fileIdToChunkHashesOrder;

    mapping(address => mapping(string => mapping(uint256 => address[])))
        private nodeAddressOfChunks;

    function storeFile(
        uint256[] memory _chunksSizeArr,
        string memory _fileName,
        string memory _fileType,
        string memory _fileEncoding,
        string memory _uniqueId,
        uint256 _fileSize,
        string memory _fileHash,
        string[] memory _chunkHashes
    ) public {
        // Iterate through each chunk and distribute them to nodes

        require(allNodes.length != 0, Constants.STORE_FILE_NO_NODES_FOUND);
        require(
            _chunkHashes.length == _chunksSizeArr.length,
            Constants.STORE_FILE_INVALID_CHUNKS
        );
        require(
            bytes(getFileHash(_uniqueId)).length <= 0,
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

                if (chunkStorageNodeTempAddress.length == allNodes.length) {
                    break;
                }

                if (selectedNodeAddress == address(0)) {
                    continue;
                }

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
        string memory _fileHash,
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
            bytes(_fileHash).length > 0,
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
        returns (FileRetrieve memory)
    {
        // Return File meta data and chunk node addresses

        FileMetadata[] memory filesArr = retrieveFilesArray();

        for (uint256 i = 0; i < filesArr.length; i++) {
            if (areStringsEqual(filesArr[i].fileId, _fileId)) {
                require(
                    msg.sender == filesArr[i].ownerAddress,
                    Constants.RETRIEVE_FILE_DETAILS_UNAUTHORIZED_CALLER_ADDRESS
                );
                return
                    FileRetrieve(
                        filesArr[i],
                        retrieveChunkNodeAddresses(_fileId),
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
            if (areStringsEqual(filesArr[i].fileId, _fileId)) {
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

    function releasePayments() public {
        uint256 userContractBalance = getUserContractBalance();
        uint256 seventyPercentBalance = (userContractBalance * 70) / 100;
        uint256 twoPercentBalance = (userContractBalance * 2) / 100;

        uint256 remainingBalanceForRetievalNodes = userContractBalance -
            seventyPercentBalance -
            twoPercentBalance;

        uint256 paymentOfEachNodesForseventyPercent = seventyPercentBalance /
            nodeAddressesForEqualPayments.length;

        for (uint256 i = 0; i < nodeAddressesForEqualPayments.length; i++) {
            address payable payee = payable(nodeAddressesForEqualPayments[i]);
            transferEther(payee, paymentOfEachNodesForseventyPercent);
        }

        delete nodeAddressesForEqualPayments;

        uint256 paymentOfEachNodesForThirtyPercent = remainingBalanceForRetievalNodes /
                nodeAddressesForFileRetrivalPayments.length;

        for (
            uint256 i = 0;
            i < nodeAddressesForFileRetrivalPayments.length;
            i++
        ) {
            address payable payee = payable(
                nodeAddressesForFileRetrivalPayments[i]
            );
            transferEther(payee, paymentOfEachNodesForThirtyPercent);
        }

        delete nodeAddressesForFileRetrivalPayments;
    }
}
