// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract NFTMarketplace is ReentrancyGuard {
    struct Listing {
        address collectionAddress;
        uint256 tokenId;
        address seller;
        uint256 price;
        uint256 indexForAllListings;
    }

    mapping(address => mapping(uint256 => Listing)) public collectionToTokenListings;
    // Req to show list of all nft's on AllNFT's page
    Listing[] public allListings;
    // Required to show list of collection which are open to listing
    // address[] public collectionsAddresses;

    event NFTListed(
        address collectionAddress,
        uint256 tokenId,
        address seller,
        uint256 price
    );

    event NFTSold(
        address collectionAddress,
        uint256 tokenId,
        address buyer,
        uint256 price
    );

    event ListingUpdated(
        address collectionAddress,
        uint256 tokenId,
        address seller,
        uint256 updatedPrice
    );

    event ListingRemoved(
        address collectionAddress,
        uint256 tokenId,
        address seller
    );

    modifier messageSenderIsNotContract(uint256 price, string memory message) {
        require(price > 0, message);
        _;
    }

    modifier onlyOwner(address owner) {
        require(msg.sender != address(0), "Not the owner");
        _;
    }

    modifier isAlreadyList(address seller) {
        require(seller == address(0), "NFT already listed");
        _;
    }

     modifier isOwner(address seller, address msgSender) {
        require(seller == msgSender, "Not the owner!");
        _;
    }

    function listNFT(address collectionAddress, uint256 tokenId, uint256 price) 
      external nonReentrant messageSenderIsNotContract(price, "Selling price should be greater then 0") {
        // require(price > 0, "Selling price should be greater then 0");
        require(msg.sender != address(0), "Not the owner");
        require(collectionToTokenListings[collectionAddress][tokenId].seller == address(0), "NFT already listed");
        require(IERC721(collectionAddress).ownerOf(tokenId) == msg.sender, "Only owner can list nft's");

        Listing memory newListing = Listing(collectionAddress, tokenId, msg.sender, price, allListings.length);

        collectionToTokenListings[collectionAddress][tokenId] = newListing;
        allListings.push(newListing);
        // collectionsAddresses.push(collectionAddress);
        emit NFTListed(collectionAddress, tokenId, msg.sender, price);
    }

    function buyNFT(address collectionAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory listing = collectionToTokenListings[collectionAddress][tokenId];

        require(listing.seller != address(0), "NFT not listed!");
        require(msg.value >= listing.price, "Please send valid number of eth to buy NFT");

        IERC721(collectionAddress).safeTransferFrom(listing.seller, msg.sender, tokenId);
        // return excess amount to buyer
        uint256 excess = msg.value - listing.price;
        if (excess > 0) {
            // console.log('excess: %i', excess);
            payable(msg.sender).transfer(excess);
        }
        // pay to seller
        payable(listing.seller).transfer(listing.price);

        delete collectionToTokenListings[collectionAddress][tokenId];
        // allListings[listing.indexForAllListings].isListed = false;
        uint256 index = listing.indexForAllListings;
        uint256 lastIndex = allListings.length - 1;
        if (index != lastIndex) {
            // Swap with the last element and update its index
            allListings[index] = allListings[lastIndex];
            allListings[index].indexForAllListings = index;
        }
        allListings.pop();

        emit NFTSold(collectionAddress, tokenId, msg.sender, listing.price);
    }

    function removeListing(address collectionAddress, uint256 tokenId) external {
        Listing memory listing = collectionToTokenListings[collectionAddress][tokenId];

        require(listing.seller == msg.sender, "Only owner can remove the listing");
        delete collectionToTokenListings[collectionAddress][tokenId];
        // allListings[listing.indexForAllListings].isListed = false;
        uint256 index = listing.indexForAllListings;
        uint256 lastIndex = allListings.length - 1;
        if (index != lastIndex) {
            // Swap with the last element and update its index
            allListings[index] = allListings[lastIndex];
            allListings[index].indexForAllListings = index;
        }
        allListings.pop();

        emit ListingRemoved(collectionAddress, tokenId, msg.sender);
    }

    function updateListingPrice(address collectionAddress, uint256 tokenId, uint256 newPrice) 
      external nonReentrant messageSenderIsNotContract(newPrice, "New price must be greater then 0") {
        require(collectionToTokenListings[collectionAddress][tokenId].seller == msg.sender, "Not the owner!");
        // require(newPrice > 0, "New price must be greater then 0");

        collectionToTokenListings[collectionAddress][tokenId].price = newPrice;
        
        emit ListingUpdated(collectionAddress, tokenId, msg.sender, newPrice);
    }

    function getAllListings() external view returns(Listing[] memory) {
        return allListings;
    }

    // function getAllCollections() external view returns(address[] memory) {
    //     return collectionsAddresses;
    // }
}

