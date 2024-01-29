// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./_ChunkManager.sol";
import "./_NodeManager.sol";

contract FileStorageManager is ChunkManager, NodeManager {
    address public owner;

    event logNumber(uint256);

    event FileUploaded(
        string fileId,
        string fileName,
        string fileType,
        bytes32 fileHash,
        uint256 fileSize,
        uint256 uploadTime,
        address uploader,
        address[] fileStorageNodeAddress
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
        address[] fileStorageNodeAddress;
    }

    // Mapping from address to FileMetadata
    mapping(address => FileMetadata[]) private addressToFile;
    address[] nodeAddressOfChunks;

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
                emit logNumber(chunkSize);
                emit logAddress(selectedNodeAddress);
                require(
                    selectedNodeAddress != address(0),
                    "No available nodes"
                );

                if (
                    !isAddressPresent(selectedNodeAddress, nodeAddressOfChunks)
                ) {
                    nodeAddressOfChunks.push(selectedNodeAddress);
                    // emit logNumber(5000);
                }

                // Pass the file ID along with node address and chunk data
                storeChunkInNode(selectedNodeAddress, _chunksArr[i], _uniqueId);

                // Update available storage of the current node
                updateAvailableStorage(
                    selectedNodeAddress,
                    nodes[selectedNodeAddress].availableStorage - chunkSize
                );
                // emit logAddress(selectedNodeAddress);
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
        string memory _uniqueId,
        uint256 _fileSize
    ) public {
        require(msg.sender != address(0));
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(bytes32(_fileHash).length > 0);
        require(_fileStorageNodeAddress.length > 0);
        require(_fileSize > 0);
        require(bytes(_uniqueId).length > 0);

        delete nodeAddressOfChunks;

        // uint256 index = uint256(keccak256(abi.encodePacked(_uniqueId)));

        //trying to make it so it tracks to right uniqueId but it is not working right now, need to think of a better way
        // for(uint256 i = 0;i <= index;i++){
        // if(i!=index){
        //     addressToFile[msg.sender].push(FileMetadata("", "", "", bytes32(0), 0, 0, address(0), "", new address[](0)));
        // }
        //  if(i==index){
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
        // }
        // }

        emit FileUploaded(
            _uniqueId,
            _fileName,
            _fileType,
            _fileHash,
            _fileSize,
            block.timestamp,
            msg.sender,
            _fileStorageNodeAddress //for debugging purposes
        );
    }

    //currently retreive function mapping is storing in array, so first file hash is stored at index 0, 2nd file at index 1...
    function retrieveFileHash(string memory _fileId)
        public
        view
        returns (FileMetadata memory)
    {
        // require(
        //     addressToFile[msg.sender][_fileId].ownerAddress == msg.sender,
        //     "Unauthenticated or file not found"
        // );

        // Return file hash

        FileMetadata[] memory filesArr = addressToFile[msg.sender];

        for (uint256 i = 0; i < filesArr.length; i++) {
            if (compareStrings(filesArr[i].fileId, _fileId)) {
                return filesArr[i];
            }
        }

        address[] memory empty;

        return FileMetadata('','','',bytes32(0),0,0,address(0),'',empty);
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

    function compareStrings(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
