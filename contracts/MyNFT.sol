// SPDX-License-Identifier: MIT
// contracts/MyNFT.sol
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    uint256 private _tokenIdCounter;

    constructor() ERC721("MyNFT", "MNFT") {
        _tokenIdCounter = 0;
    }

    function mint(address to) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter++;
        _mint(to, tokenId);
        return tokenId;
    }
}