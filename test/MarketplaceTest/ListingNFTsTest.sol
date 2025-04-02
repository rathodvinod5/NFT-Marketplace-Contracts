// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/Marketplace.sol";
import "../../src/ERC721CollectionContract.sol";

contract NFTMarketPlaceTest is Test {
    NFTMarketplace marketplace;
    ERC721CollectionContract collection;
    address seller;
    address buyer;
    string tokenURI;

    function setUp() public {
        tokenURI = "ipfs://QmTestHash1234567890abcdef";
        seller = vm.addr(1);
        buyer = vm.addr(2);

        vm.prank(seller);
        collection = new ERC721CollectionContract("Test Token", "TKN", seller);
        marketplace = new NFTMarketplace();
    }

    // 1. Should allow an NFT owner to list their NFT for sale
    // 7. Should add the NFT listing to allListings upon successful listing.
    function test_listNFTs() public {
        uint256 sellingPrice = 1 ether;

        vm.startPrank(seller);
        uint256 tokenId = collection.mint(seller, tokenURI);
        marketplace.listNFT(address(collection), tokenId, sellingPrice);
        collection.approve(address(marketplace), tokenId);
        vm.stopPrank();

        NFTMarketplace.Listing[] memory listings = marketplace.getAllListings();
        assertEq(listings.length, 1, "Error in length after minting");
        assertEq(listings[0].collectionAddress, address(collection), "Collection addresses mismatch");
        assertEq(listings[0].tokenId, tokenId, "Token id mismatch");
        assertEq(listings[0].seller, seller, "Seller addrss mismatch");
        assertEq(listings[0].price, sellingPrice, "Selling price mismatch");
    }

    // 2. Should revert if the price is set to zero
    function test_revertIfPriceIsZero() public {
        vm.startPrank(seller);
        uint256 tokenId = collection.mint(seller, tokenURI);
        // Approve the marketplace to transfer the NFT
        collection.approve(address(marketplace), tokenId);

        vm.expectRevert("Selling price should be greater then 0");
        marketplace.listNFT(address(collection), tokenId, 0 ether);
        
        vm.stopPrank();
    }

    // 3. Should revert if the sender is zero address
    function test_revertIfZenderIsZeroAddress() public {
        vm.startPrank(seller);
        uint256 tokenId = collection.mint(seller, tokenURI);
        collection.approve(address(marketplace), tokenId);
        vm.stopPrank();

        vm.expectRevert("Not the owner");
        vm.prank(address(0));
        marketplace.listNFT(address(collection), tokenId, 1 ether);
    }

    // 4. Should revert if the NFT is already listed
    function test_shouldRevertIfNFTAlreadyListed() public {
        vm.startPrank(seller);
        uint256 tokenId = collection.mint(seller, tokenURI);
        collection.approve(address(marketplace), tokenId);
        marketplace.listNFT(address(collection), tokenId, 0.5 ether);
        
        vm.expectRevert("NFT already listed");
        marketplace.listNFT(address(collection), tokenId, 0.5 ether);
        vm.stopPrank();
    }

    // 5. Should revert if the caller is not the owner of the NFT
    function test_revertIfCallerIsNotTheOwner() public {
        vm.startPrank(seller);
        uint256 tokenId = collection.mint(seller, tokenURI);
        collection.approve(address(marketplace), tokenId);
        vm.stopPrank();

        vm.startPrank(buyer);
        vm.expectRevert("Only owner can list nft's");
        marketplace.listNFT(address(collection), tokenId, 0.5 ether);
        vm.stopPrank();
    }

    // 6. Should add the NFT to the listings mapping upon successful listing
    function test_forSuccessfullListing() public {
        vm.startPrank(seller);
        uint256 tokenId = collection.mint(seller, tokenURI);
        marketplace.listNFT(address(collection), tokenId, 0.5 ether);
        collection.approve(address(marketplace), tokenId);
        vm.stopPrank();

        (
            address collectionAddress, 
            uint256 _tokenId,
            address _seller,
            uint256 price,
        ) = marketplace.collectionToTokenListings(address(collection), tokenId);

        assertEq(address(collectionAddress), address(collection), "Collection address mismatch");
        assertEq(tokenId, _tokenId, "Token id mismatch");
        assertEq(seller, _seller, "Collection address mismatch");
        assertEq(price, 0.5 ether, "Collection address mismatch");
    }
}