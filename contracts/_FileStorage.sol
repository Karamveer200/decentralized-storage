// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract FileStorageManager {
    address public owner;
    uint256 public availableStorage;
    uint256 public fileIdIndex = 1; // Starting from 1 to avoid using default value 0
    mapping(string => uint256) private fileNameToFileId; // Mapping from fileName to fileId
    mapping(uint256 => File) private fileIdToFile; // Mapping from fileId to File
    mapping(uint256 => address) private fileIdToUserId; // Mapping from fileId to userId

    event FileStored(string fileName, uint256 fileId, uint256 newAvailableStorage); // need to return the same file id
    event FileRetrieved(string fileName, string content);// need to return the same file id
    event FileDeleted(string fileName, uint256 newAvailableStorage);

    struct File { // Struct to store file details
        string content;
        string fileName;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthenticated");
        _;
    }

    constructor(uint256 initialStorage) {
        owner = msg.sender;
        availableStorage = initialStorage;
    }

    function storeFile(string memory fileName, string memory content),  public {// one more argument 
        uint256 fileSize = bytes(content).length;
        require(availableStorage >= fileSize, "No storage available");
        
        uint256 currentFileId = fileIdIndex++;
        fileNameToFileId[fileName] = currentFileId;
        fileIdToFile[currentFileId] = File(content, fileName);
        fileIdToUserId[currentFileId] = msg.sender;

        availableStorage -= fileSize;

        emit FileStored(fileName, currentFileId, availableStorage);// pass back the file id from aruments
    }


    function retrieveFile(string memory fileName) public view returns (string memory) {
        uint256 fileId = fileNameToFileId[fileName];
        require(fileId != 0, "File not found");
        return fileIdToFile[fileId].content;
    }

    function deleteFile(string memory fileName) public {// the id will be passed from the front end, use this 
        uint256 fileId = fileNameToFileId[fileName];
        require(fileId != 0, "File not found");
        require(fileIdToUserId[fileId] == msg.sender || msg.sender == owner, "Unauthorized");

        uint256 fileSize = bytes(fileIdToFile[fileId].content).length;

        availableStorage += fileSize;

        delete fileNameToFileId[fileName];
        delete fileIdToFile[fileId];
        delete fileIdToUserId[fileId];

        emit FileDeleted(fileName, availableStorage);
    }
}
