// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        address contractAddress;
        uint256 tokenId;
        uint256 price;
        bool isERC1155;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    address[] public collectionAddresses;
    Listing[] public allListings;

    event NFTListed(
        address nftAddress,
        address seller,
        uint256 tokenId,
        uint256 price
    );
    event NFTSold(
        address nftAddress,
        address buyer,
        uint256 tokenId,
        uint256 price
    );
    event ListingRemoved(
        address nftAddress,
        address seller,
        uint256 tokenId
    );
    event ListingUpdated(
        address nftAddress,
        address seller,
        uint256 tokenId,
        uint256 updatedPrice
    );

    function listNFT(address nftAddress, address seller, uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "Price should be greater then 0");
        require(listings[nftAddress][tokenId].seller == address(0), "Token already listed");

        require(IERC721(nftAddress).ownerOf(tokenId) == seller, "Not a owner of this token");

        listings[nftAddress][tokenId] = Listing(seller, nftAddress, tokenId, price, false);
        allListings.push(listings[nftAddress][tokenId]);
        collectionAddresses.push(nftAddress);
        emit NFTListed(nftAddress, seller, tokenId, price);
    }
}

