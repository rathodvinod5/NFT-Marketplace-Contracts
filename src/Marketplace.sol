// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        address nftContractAddress;
        uint256 tokenId;
        address seller;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    address[] public collectionsAddresses;
    Listing[] public allListings;

    event NFTListed(
        address nftContractAddress,
        uint256 tokenId,
        address seller,
        uint256 price
    );

    event NFTSold(
        address nftContractAddress,
        uint256 tokenId,
        address seller,
        uint256 price
    );

    event ListingUpdated(
        address nftContractAddress,
        uint256 tokenId,
        address seller,
        uint256 updatedPrice
    );

    event ListingRemoved(
        address nftContractAddress,
        uint256 tokenId,
        address seller
    );

    function listNFT(address nftContractAddress, uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "Price should be greater then 0");
        require(msg.sender != address(0), "Not the owner");
        require(listings[nftContractAddress][tokenId].seller == address(0), "Already listed");
        require(IERC721(nftContractAddress).ownerOf(tokenId) == msg.sender, "Only owner can list nft's");
        Listing memory newListing = Listing(nftContractAddress, tokenId, msg.sender, price);

        listings[nftContractAddress][tokenId] = newListing;
        allListings.push(newListing);
        collectionsAddresses.push(nftContractAddress); // why this
        emit NFTListed(nftContractAddress, tokenId, msg.sender, price);
    }

    function buyNFT(address nftContractAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory listing = listings[nftContractAddress][tokenId];
        require(msg.value > listing.price, "Please send valid number of eth to buy");
        require(listing.seller != address(0), "NFT no listed!");

        payable(listing.seller).transfer(msg.value);
        delete listings[nftContractAddress][tokenId];

        IERC721(nftContractAddress).safeTransferFrom(listing.seller, msg.sender, tokenId);
        emit NFTSold(nftContractAddress, tokenId, msg.sender, listing.price);
    }

    function removeListing(address nftContractAddress, uint256 tokenId) external {
        require(listings[nftContractAddress][tokenId].seller == msg.sender, "You are not the seller!");
        delete listings[nftContractAddress][tokenId];
        emit ListingRemoved(nftContractAddress, tokenId, msg.sender);
    }

    function updateListing(address nftContractAddress, uint256 tokenId, uint256 newPrice) external nonReentrant {
        require(listings[nftContractAddress][tokenId].seller == msg.sender, "Not the owner!");
        require(newPrice > 0, "New price must be greater then 0");
        listings[nftContractAddress][tokenId].price = newPrice;
        emit ListingUpdated(nftContractAddress, tokenId, msg.sender, newPrice);
    }

    function getAllListings() external view returns(Listing[] memory) {
        return allListings;
    }

    function getAllCollections() external view returns(address[] memory) {
        return collectionsAddresses;
    }
}

