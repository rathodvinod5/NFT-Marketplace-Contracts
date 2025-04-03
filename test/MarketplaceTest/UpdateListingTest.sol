// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ERC721CollectionContract.sol";
import "../../src/Marketplace.sol";

contract UpdateListingTest is Test {
    NFTMarketplace marketplace;
    ERC721CollectionContract collectionAddr;
    uint256 tokenId;
    address seller;
    address buyer;
    string tokenURI = "ipfs://QmTestHash1234567890abcdef";

    function setUp() public {
        seller = vm.addr(1);
        buyer = vm.addr(2);

        vm.startPrank(seller);
        marketplace = new NFTMarketplace();
        collectionAddr = new ERC721CollectionContract("Test", "TKN", seller);
        tokenId = collectionAddr.mint(seller, tokenURI);
        marketplace.listNFT(address(collectionAddr), tokenId, 1 ether);
        vm.stopPrank();
    }

    // Should allow the seller to update the price of their listed NFT
    // Should update the price in the listings mapping upon successful update
    function test_shouldAllowOnwerToUpdateThePriceOfListing() public {
        vm.prank(seller);
        marketplace.updateListingPrice(address(collectionAddr), tokenId, 0.5 ether);

        (,,, uint256 price, ) = marketplace.collectionToTokenListings(address(collectionAddr), tokenId);
        assertEq(price, 0.5 ether, "Price mismatch");
    }

    // Should revert if a non-seller tries to update the listing
    function test_shouldRevertIfNonSellerTriesToUpdateListing() public {
        vm.expectRevert("Not the owner!");
        vm.prank(buyer);
        marketplace.updateListingPrice(address(collectionAddr), tokenId, 0.5 ether);
    }

    // Should revert if the new price is set to zero
    function test_shouldRevertIfNewPriceIsSetToZero() public {
        vm.expectRevert("New price must be greater then 0");
        vm.prank(seller);
        marketplace.updateListingPrice(address(collectionAddr), tokenId, 0 ether);
    }

    // Should emit a ListingUpdated event upon successful price update
    function test_shouldFireListingUpdateEventOnSuccess() public {
        vm.expectEmit(true, true, true, true);
        emit NFTMarketplace.ListingUpdated(address(collectionAddr), tokenId, seller, 0.5 ether);

        vm.prank(seller);
        marketplace.updateListingPrice(address(collectionAddr), tokenId, 0.5 ether);
    }
}