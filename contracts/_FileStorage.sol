// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";
import "hardhat/console.sol";

contract FileStorageManager is ChunkManager, NodeManager {
    address public owner;

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
        string[] memory _chunksArr,
        string memory _fileName,
        string memory _fileType,
        string memory _fileEncoding,
        string memory _uniqueId,
        uint256 _fileSize
    ) public {
        // Iterate through each chunk and distribute them to nodes
        console.log("00000", _chunksArr.length);

        require(allNodes.length != 0, "No available nodes found");

        for (uint256 i = 0; i < _chunksArr.length; i++) {
            delete chunkStorageNodeTempAddress;

            uint256 chunkSize = bytes(_chunksArr[i]).length;

            uint256 chunkDuplicationCounter = 0;

            uint256 maxDuplicationNum = numMaxChunksDuplication;

            if (allNodes.length < 3) {
                maxDuplicationNum = allNodes.length;
            }

            console.log("11111", chunkDuplicationCounter, maxDuplicationNum);

            while (chunkDuplicationCounter < maxDuplicationNum) {
                address selectedNodeAddress = findAvailableNode(chunkSize);

                console.log("22222", selectedNodeAddress);

                emit logAddress(selectedNodeAddress);

                chunkStorageNodeTempAddress.push(selectedNodeAddress);

                emit logAddress2(selectedNodeAddress);

                chunkDuplicationCounter++;

                // Pass the file ID along with node address and chunk data
                storeChunkInNode(selectedNodeAddress, _chunksArr[i], _uniqueId, i);

                // Update available storage of the current node
                updateAvailableStorage(
                    selectedNodeAddress,
                    nodes[selectedNodeAddress].availableStorage - chunkSize
                );

                // emit logAddress(selectedNodeAddress);
            }
        }

        delete chunkStorageNodeTempAddress;

        bytes32 getFileHash = createHash(_chunksArr);

        storeFileHash(getFileHash, _uniqueId);

        storeFileMetadata(
            _fileName,
            _fileType,
            getFileHash,
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
        require(msg.sender != address(0));
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(bytes32(_fileHash).length > 0);
        require(_fileSize > 0);
        require(bytes(_uniqueId).length > 0);

        addressToFile[msg.sender].push(
            FileMetadata(
                _uniqueId,
                _fileName,
                _fileType,
                _fileHash,
                _fileSize,
                block.timestamp,
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
            block.timestamp,
            msg.sender
        );
    }

    function retrieveFileHash(string memory _fileId)
        public
        view
        returns (FileRetrieve memory)
    {
        // Return File meta data and chunk node addresses

        FileMetadata[] memory filesArr = addressToFile[msg.sender];

        for (uint256 i = 0; i < filesArr.length; i++) {
            if (compareStrings(filesArr[i].fileId, _fileId)) {
                return FileRetrieve(filesArr[i], retrieveChunkNodeAddresses(_fileId));
            }
        }

        address [] memory dummyAddr;
        FileMetadata memory dummy = FileMetadata("", "", "", bytes32(0), 0, 0, address(0), "");
        return FileRetrieve(dummy, dummyAddr);
    }

    function deleteFile(string memory _fileId) public {
        require(addressToFile[msg.sender].length > 0, "Invalid file id");

        FileMetadata[] memory filesArr = addressToFile[msg.sender];

        uint256 lastIndex = filesArr.length - 1;

        FileMetadata memory lastFile = filesArr[lastIndex];

        FileMetadata memory fileToRemove;

        // SWAP last and fileId index

        for (uint256 i = 0; i < filesArr.length; i++) {
            if (compareStrings(filesArr[i].fileId, _fileId)) {
                fileToRemove = filesArr[i];
                addressToFile[msg.sender][i] = lastFile;
            }
        }
        addressToFile[msg.sender][lastIndex] = fileToRemove;

        // Delete last index as its the intended file
        addressToFile[msg.sender].pop();

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
