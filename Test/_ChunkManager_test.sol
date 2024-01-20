// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin

import "remix_accounts.sol";
import "../contracts/_ChunkManager.sol";

contract ChunkManagerTest {
    // Instance of ChunkManager
    ChunkManager chunkManager;

    // Runs before all tests
    function beforeAll() public {
        // Create an instance of ChunkManager
        chunkManager = new ChunkManager();
    }

    // Test chunking functionality
    function testChunkContent() public {
        string memory content = "This is a test content.";
        string[] memory chunks = chunkManager.chunkContent(content);

        // Assert the number of chunks
        Assert.equal(chunks.length, 2, "Number of chunks should be 2");

        // Assert the content of each chunk
        Assert.equal(chunks[0], "This is a test content.", "Incorrect content in the first chunk");
        Assert.equal(chunks[1], "", "Second chunk should be empty");
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
    