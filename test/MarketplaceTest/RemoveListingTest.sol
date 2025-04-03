// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ERC721CollectionContract.sol";
import "../../src/Marketplace.sol";

contract RemoveNFTFromListing is Test {
    ERC721CollectionContract collectionAddr;
    NFTMarketplace marketplace;
    address buyer;
    address seller;
    uint tokenId;
    string tokenURI = "ipfs://QmTestHash1234567890abcdef";

    function setUp() public {
        seller = vm.addr(1);
        buyer = vm.addr(2);

        vm.startPrank(seller);
        collectionAddr = new ERC721CollectionContract("Test", "TKN", seller);
        marketplace = new NFTMarketplace();
        tokenId = collectionAddr.mint(seller, tokenURI);
        vm.stopPrank();
    }

    // Should allow the seller to remove their own NFT listing
    function test_allowUsersToRemoveTheirNFT() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(collectionAddr), tokenId, 0.5 ether);
        NFTMarketplace.Listing[] memory listings = marketplace.getAllListings();
        assertEq(address(listings[0].collectionAddress), address(collectionAddr), "Collection Addr mismatch");
        assertEq(listings[0].tokenId, tokenId, "Tokend mismatch");
        assertEq(listings[0].seller , seller, "Owner mismatch");

        marketplace.removeListing(address(collectionAddr), tokenId);
        NFTMarketplace.Listing[] memory newListings = marketplace.getAllListings();
        assertEq(newListings.length, 0, "Listing still exists");
        vm.stopPrank();
    }

    // Should revert if a non-seller tries to remove the listing
    function test_shouldRemoveWhenNonSellerTriesToRemoveTheListing() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(collectionAddr), tokenId, 0.5 ether);
        NFTMarketplace.Listing[] memory listings = marketplace.getAllListings();
        assertEq(address(listings[0].collectionAddress), address(collectionAddr), "Collection Addr mismatch");
        assertEq(listings[0].tokenId, tokenId, "Tokend mismatch");
        assertEq(listings[0].seller , seller, "Owner mismatch");
        vm.stopPrank();

        vm.expectRevert("Only owner can remove the listing");
        vm.prank(buyer);
        marketplace.removeListing(address(collectionAddr), tokenId);
    }

    // Should remove the listing from listings after successful removal
    function test_shouldRemoveTheListingAfterSuccessfullRemoval() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(collectionAddr), tokenId, 0.5 ether);
        NFTMarketplace.Listing[] memory listings = marketplace.getAllListings();
        assertEq(address(listings[0].collectionAddress), address(collectionAddr), "Collection Addr mismatch");
        assertEq(listings[0].tokenId, tokenId, "Tokend mismatch");
        assertEq(listings[0].seller , seller, "Owner mismatch");

        marketplace.removeListing(address(collectionAddr), tokenId);

        NFTMarketplace.Listing[] memory newListings = marketplace.getAllListings();
        assertEq(address(newListings[0].collectionAddress), address(collectionAddr), "Collection Addr mismatch");
        assertEq(newListings[0].tokenId, tokenId, "Tokend mismatch");
        assertEq(newListings[0].seller , seller, "Owner mismatch");
        vm.stopPrank();
    }

    // Should emit a ListingRemoved event upon successful removal
    function test_shouldEmitAnEventUponRemoval() public {
        vm.startPrank(seller);
        marketplace.listNFT(address(collectionAddr), tokenId, 0.5 ether);

        vm.expectEmit(true, true, true, true);
        emit NFTMarketplace.ListingRemoved(address(collectionAddr), tokenId, seller);

        marketplace.removeListing(address(collectionAddr), tokenId);
        vm.stopPrank();
    }
} 