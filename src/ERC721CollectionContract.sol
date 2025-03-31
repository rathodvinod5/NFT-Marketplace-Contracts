// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721CollectionContract is ERC721URIStorage, Ownable {
    uint256 public tokenIdCounter;
    address public factory;
    uint256[] public mintedTokens;

    constructor(string memory name, string memory symbol, address owner) 
        ERC721(name, symbol) 
        Ownable(owner) 
    {
        // transferOwnership(msg.sender);
    }

    function mint(address to, string memory tokenURI) public returns(uint256) {
        require(msg.sender == owner() || msg.sender == factory, "Not authorized");
        
        tokenIdCounter++;
        uint256 newTokenId = tokenIdCounter;
        // _safeMint(msg.sender, newTokenId);
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        mintedTokens.push(newTokenId);
        return newTokenId;
    }

    function getMintedTokensForTheCollection() public view returns(uint256[] memory) {
        return mintedTokens;
    }
}