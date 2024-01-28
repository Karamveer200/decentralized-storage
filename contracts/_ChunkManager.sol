// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ChunkManager {
    uint104 public numMaxChunksDuplication = 3;

    function chunkContent(string memory content)
        public
        pure
        returns (string[] memory)
    {
        //Changed to public for testing
        uint256 chunkSize = 32;
        uint256 numChunks = (bytes(content).length + chunkSize - 1) / chunkSize;
        string[] memory chunks = new string[](numChunks);

        for (uint256 i = 0; i < numChunks; i++) {
            uint256 start = i * chunkSize;
            uint256 end = start + chunkSize;
            if (end > bytes(content).length) {
                end = bytes(content).length;
            }
            bytes memory chunkBytes = new bytes(end - start);
            for (uint256 j = start; j < end; j++) {
                chunkBytes[j - start] = bytes(content)[j];
            }
            chunks[i] = string(chunkBytes);
        }

        return chunks;
    }

    function concatenateChunks(string[] memory chunks)
        public
        pure
        returns (string memory)
    {
        //Changed to public for testing
        uint256 totalLength = 0;
        for (uint256 i = 0; i < chunks.length; i++) {
            totalLength += bytes(chunks[i]).length;
        }

        bytes memory result = new bytes(totalLength);
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < chunks.length; i++) {
            bytes memory chunkBytes = bytes(chunks[i]);
            for (uint256 j = 0; j < chunkBytes.length; j++) {
                result[currentIndex++] = chunkBytes[j];
            }
        }

        return string(result);
    }

    function getNumMaxDuplicationCount() public view returns (uint104) {
        return numMaxChunksDuplication;
    }
}
