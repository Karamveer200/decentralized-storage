
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract FileStorageManager {
    address public owner;
    uint256 public availableStorage;
    uint256 public fileIdIndex = 0;
    mapping(string => string) private files; //mapping fileName to fileContent
    mapping(uint256 => Files) private fileId; //mapping fileId to fileName,fileContent
    mapping(uint256 => address) private userId; //mapping fileId to userId

    event FileStored(string fileName, uint256 newAvailableStorage);
    event FileRetrieved(string fileName, string content);
    event FileDeleted(string fileName, uint256 newAvailableStorage);

    struct Files{                          //made a struct so I can map fileName,fileContent
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

    function storeFile(string memory fileName, string memory content) public {
        
        uint256 fileSize = bytes(content).length;
        require(availableStorage - fileSize > 0, "No storage available"); //changed to availablestorage-filesize, moved file size above since it was out of scope earlier
        

        files[fileName] = content;
        availableStorage -= fileSize;

        fileId[fileIdIndex] = Files(fileName,content); //added mapping from fileId to fileName,fileContent
        userId[fileIdIndex] = msg.sender; //added mapping from fileId to userId


        fileIdIndex++;

        emit FileStored(fileName, availableStorage);
    }

    function retrieveFile(string memory fileName) external view returns (string memory) {
        return files[fileName];
    }

    function deleteFile(string memory fileName) external onlyOwner {
        require(bytes(files[fileName]).length > 0, "File not found");

        uint256 fileSize = bytes(files[fileName]).length;

        delete files[fileName];
        fileIdIndex--;
        delete userId[fileIdIndex]; //same as store but just deletion
        delete fileId[fileIdIndex]; //same as store but just deletion

        availableStorage += fileSize;

        emit FileDeleted(fileName, availableStorage);
    }
}