
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract FileStorageManager {
    address public owner;
    uint256 public availableStorage;
    mapping(string => string) private files;

    event FileStored(string fileName, uint256 newAvailableStorage);
    event FileRetrieved(string fileName, string content);
    event FileDeleted(string fileName, uint256 newAvailableStorage);

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthenticated");
        _;
    }

    constructor(uint256 initialStorage) {
        owner = msg.sender;
        availableStorage = initialStorage;
    }

    function storeFile(string memory fileName, string memory content) public {
        require(availableStorage > 0, "No storage available");
        uint256 fileSize = bytes(content).length;

        files[fileName] = content;
        availableStorage -= fileSize;

        emit FileStored(fileName, availableStorage);
    }

    function retrieveFile(string memory fileName) external view returns (string memory) {
        return files[fileName];
    }

    function deleteFile(string memory fileName) external onlyOwner {
        require(bytes(files[fileName]).length > 0, "File not found");

        uint256 fileSize = bytes(files[fileName]).length;

        delete files[fileName];

        availableStorage += fileSize;

        emit FileDeleted(fileName, availableStorage);
    }
}