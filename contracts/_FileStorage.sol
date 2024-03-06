// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";
import "./_UserManager.sol";
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
        string[] chunkHashesOrder;
    }

    address[] chunkStorageNodeTempAddress;
    address[] paymentReleaseNodeTempAddress;

    mapping(address => FileMetadata[]) public addressToFile;

    mapping(string => string[]) public fileIdToChunkHashesOrder;

    mapping(address => mapping(string => mapping(uint256 => address[])))
        private nodeAddressOfChunks;

    constructor() NodeManager() {
        owner = msg.sender;
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
            bytes32(0),
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

    function releasePayments() public {
        uint256 userContractBalance = getContractBalance();
        uint256 seventyPercentBalance = (userContractBalance * 70) / 100;
        uint256 twoPercentBalance = (userContractBalance * 2) / 100;

        uint256 remainingBalanceForRetievalNodes = userContractBalance -
            seventyPercentBalance -
            twoPercentBalance;

        for (uint256 i = 0; i < userAddresses.length; i++) {
            FileMetadata[] memory filesArr = addressToFile[userAddresses[i]];

            for (uint256 j = 0; j < filesArr.length; j++) {
                address[] memory nodesAddress = nodeChunksAddresses[
                    filesArr[j].fileId
                ];
                for (uint256 k = 0; k < nodesAddress.length; k++) {
                    if (!isBadActor(nodesAddress[k])) {
                        paymentReleaseNodeTempAddress.push(nodesAddress[k]);
                    }
                }
            }
        }

        uint256 paymentOfEachNodesForseventyPercent = seventyPercentBalance /
            paymentReleaseNodeTempAddress.length;

        for (uint256 i = 0; i < paymentReleaseNodeTempAddress.length; i++) {
            address payable payee = payable(paymentReleaseNodeTempAddress[i]);
            transferEther(payee, paymentOfEachNodesForseventyPercent);
        }
    }
}
