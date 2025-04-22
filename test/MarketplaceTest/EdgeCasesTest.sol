// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/Marketplace.sol";
import "../../src/ERC721CollectionContract.sol";

contract NFTMarketplace_ListWithoutOwnership_Test is Test {
    NFTMarketplace public marketplace;
    ERC721CollectionContract public collectionAddr;
    uint256 tokenId;
    address seller = vm.addr(1);
    address buyer = vm.addr(2);

    function setUp() public {
        vm.startPrank(seller);
        marketplace = new NFTMarketplace();
        collectionAddr = new ERC721CollectionContract("MyNFT", "NFT", seller);
        // Mint NFT to seller
        tokenId = collectionAddr.mint(seller, "ipfs://example");

        // Give ETH to both accounts for interaction
        vm.deal(seller, 10 ether);
        vm.deal(buyer, 10 ether);

        vm.stopPrank();
    }

    // Should revert if a seller tries to list an NFT they no longer own
    function test_revertIfNotOwnerTriesToList() public {
        vm.startPrank(seller);

        // Seller transfers NFT to someone else (buyer)
        collectionAddr.transferFrom(seller, buyer, tokenId);

        // Seller tries to list NFT they no longer own
        vm.expectRevert("Only owner can list nft's");
        marketplace.listNFT(address(collectionAddr), tokenId, 1 ether);
        vm.stopPrank();
    }

    // Should successfully transfer ETH if the seller is an externally owned account (EOA)
    function test_NFTMarketplace_EOAETHTransfer_Test() public {
        vm.startPrank(seller);
        collectionAddr.approve(address(marketplace), tokenId);
        marketplace.listNFT(address(collectionAddr), tokenId,  1 ether);
        vm.stopPrank();

        vm.prank(buyer);
        marketplace.buyNFT{ value: 1 ether }(address(collectionAddr), tokenId);

        uint256 balanceBefore = seller.balance;
        assertEq(balanceBefore + 1 ether, seller.balance, "Seller Balance mismatch after selling");
    }
}