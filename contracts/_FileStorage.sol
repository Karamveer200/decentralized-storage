// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract FileStorageManager {
    address public owner;
    uint256 public availableStorage;

    mapping(string => File) private fileIdToFile; // Mapping from fileId to File
    mapping(string => address) private fileIdToUserId; // Mapping from fileId to userId

    event FileStored(string fileName, string fileId, uint256 newAvailableStorage); // need to return the same file id
    event FileRetrieved(string fileName, string content);// need to return the same file id
    event FileDeleted(uint256 newAvailableStorage);

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

    function storeFile(string memory fileName, string memory content, string memory uniqueId)  public {// one more argument 
        uint256 fileSize = bytes(content).length;
        require(availableStorage >= fileSize, "No storage available");
        
        fileIdToFile[uniqueId] = File(content, fileName);
        fileIdToUserId[uniqueId] = msg.sender;

        availableStorage -= fileSize;

        emit FileStored(fileName, uniqueId, availableStorage);// pass back the file id from aruments
    }


    function retrieveFile(string memory fileId) public view returns (string memory) {
        // require(fileId != '', "File not found");
        return fileIdToFile[fileId].content;
    }

    function deleteFile(string memory fileId) public {// the id will be passed from the front end, use this 
        // require(fileId != 0, "File not found");
        require(fileIdToUserId[fileId] == msg.sender || msg.sender == owner, "Unauthorized");

        uint256 fileSize = bytes(fileIdToFile[fileId].content).length;

        availableStorage += fileSize;

        delete fileIdToFile[fileId];
        delete fileIdToUserId[fileId];

        emit FileDeleted(availableStorage);
    }
}
