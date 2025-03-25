// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721CollectionContract is ERC721URIStorage, Ownable {
    uint256 public tokenIdCounter;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {
        transferOwnership(msg.sender);
    }

    function createCollection(string memory tokenURI) public {
        tokenIdCounter++;
        uint256 newTokenId = tokenIdCounter;
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
    }
}