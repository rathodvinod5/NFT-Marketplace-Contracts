// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ERC721CollectionContract.sol";
import "../../src/Marketplace.sol";

contract RetrieveListingsTest is Test {
    NFTMarketplace marketplace;
    ERC721CollectionContract collectionAddr1;
    ERC721CollectionContract collectionAddr2;
    address seller;
    address buyer;
    uint256 price = 1 ether;
    string tokenURI = "ipfs://QmTestHash1234567890abcdef";

    function setUp() public {
        seller = vm.addr(1);
        buyer = vm.addr(2);

        vm.startPrank(seller);
        collectionAddr1 = new ERC721CollectionContract("Test1", "TKN1", seller);
        collectionAddr2 = new ERC721CollectionContract("Test2", "TKN2", seller);
        marketplace = new NFTMarketplace();
        vm.stopPrank();
    }

    // Should return all unique NFT contract addresses using getAllCollections()
    function test_returnAllNFTContractAddress() public {
        vm.startPrank(seller);
         // Mint NFTs in different collections
        uint256 tokenId1 = collectionAddr1.mint(seller, "https://example.com/1");
        uint256 tokenId2 = collectionAddr2.mint(seller, "https://example.com/2");

        // Approve marketplace to transfer NFTs
        // collectionAddr1.approve(address(marketplace), tokenId1);
        // collectionAddr2.approve(address(marketplace), tokenId2);

        // List NFTs from both collections
        marketplace.listNFT(address(collectionAddr1), tokenId1, price);
        marketplace.listNFT(address(collectionAddr2), tokenId2, price);

        // Fetch the collection addresses
        NFTMarketplace.Listing[] memory listings = marketplace.getAllListings();

        // Verify that the returned list contains both unique collection addresses
        assertEq(listings.length, 2, "Should return exactly 2 unique collections");
        assertEq(listings[0].collectionAddress, address(collectionAddr1), "First collection address should match");
        assertEq(listings[1].collectionAddress, address(collectionAddr2), "Second collection address should match");
        vm.stopPrank();
    }

    // Should return an empty array if no listings exist
    function test_shouldReturnEmptyList() public view {
        // Fetch the collection addresses
        NFTMarketplace.Listing[] memory listings = marketplace.getAllListings();

        // Verify that the returned list contains both unique collection addresses
        assertEq(listings.length, 0, "Should return exactly 2 unique collections");
    }
}