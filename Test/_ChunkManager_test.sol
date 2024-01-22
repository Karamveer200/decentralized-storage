// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 
import "../contracts/_ChunkManager.sol";

contract ChunkManagerTest {
    // Instance of ChunkManager
    ChunkManager chunkManager;

    // Runs before all tests
    function beforeAll() public {
        // Create an instance of ChunkManager
        chunkManager = new ChunkManager();
    }

    event logNumber (uint256);


    // Test chunking functionality
    function testChunkContent() public {
        string memory content = "Testing content.";
        string[] memory chunks = chunkManager.chunkContent(content);
        uint256 numberOfChunks = chunks.length;
        emit logNumber(numberOfChunks);            
        
        Assert.equal(chunks.length, 1, "incorrect");
 

        // Assert the content of each chunk
        Assert.equal(chunks[0], content, "Incorrect content in the first chunk");
    }

    // Test concatenation functionality
    function testConcatenateChunks() public {
        string[] memory chunks = new string[](2);
        chunks[0] = "This is ";
        chunks[1] = "a test.";

        string memory concatenatedContent = chunkManager.concatenateChunks(chunks);

        // Assert the concatenated content
        Assert.equal(concatenatedContent, "This is a test.", "Incorrect concatenated content");
    }
}
    