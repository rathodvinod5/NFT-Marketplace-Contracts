// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/Marketplace.sol";
import "../../src/ERC721CollectionContract.sol";
import "forge-std/Vm.sol";


// 2. Test Buying NFTs
contract BuyingNFTTest is Test {
    ERC721CollectionContract collectionAddr;
    NFTMarketplace marketplace;
    address seller;
    address buyer;
    string tokenURI;
    uint256 sellingPrice = 1 ether;
    // Vm vm = Vm(VM_ADDRESS); // Cheatcode to manipulate sender and ETH balance

    function setUp() public {
        tokenURI = "ipfs://QmTestHash1234567890abcdef";
        seller = vm.addr(1);
        buyer = vm.addr(2);

        vm.prank(seller);
        collectionAddr = new ERC721CollectionContract("Test", "TKN", seller);
        marketplace = new NFTMarketplace();
    }


    // Should allow a buyer to purchase a listed NFT
    // Should remove the NFT from the listings mapping after purchase
    // Should transfer ownership of the NFT to the buyer
    function test_allowBuyerToPurchaseListedNFT() public {
        vm.startPrank(seller);
        uint256 tokenId = collectionAddr.mint(seller, tokenURI);
        collectionAddr.approve(address(marketplace), tokenId);
        marketplace.listNFT(address(collectionAddr), tokenId, sellingPrice);
        vm.stopPrank();

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        marketplace.buyNFT{value: sellingPrice}(address(collectionAddr), tokenId);

        // validate whether the owner is updated or not
        assertEq(collectionAddr.ownerOf(tokenId), buyer, "Owner mismatch after purchase");

        // check whether the nft is removed from marketplace or not
        (,, address _seller, ,) = marketplace.collectionToTokenListings(address(collectionAddr), tokenId);
        assertEq(_seller, address(0), "NFT not removed from marketplace");
    }

    // Should transfer the correct amount of ETH to the seller
    function test_transferCorrentAmountOfEthToSeller() public {
        vm.startPrank(seller);
        uint256 previousAmount = address(seller).balance;
        uint256 tokenId = collectionAddr.mint(seller, tokenURI);
        collectionAddr.approve(address(marketplace), tokenId);
        marketplace.listNFT(address(collectionAddr), tokenId, sellingPrice);
        vm.stopPrank();

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        marketplace.buyNFT{value: sellingPrice}(address(collectionAddr), tokenId);

        // assertGe(address(seller).balance, previousAmount + sellingPrice, "Seller didnot receive enough balance");
        assertEq(address(seller).balance, previousAmount + sellingPrice, "Seller didnot receive enough balance");
    }

    // Should revert if the sent ETH amount is less than the listed price
    function test_revertIfEthIsLessThenSellingPrice() public {
        vm.startPrank(seller);
        uint256 tokenId = collectionAddr.mint(seller, tokenURI);
        collectionAddr.approve(address(marketplace), tokenId);
        marketplace.listNFT(address(collectionAddr), tokenId, sellingPrice);
        vm.stopPrank();

        vm.deal(buyer, 2 ether);
        vm.expectRevert("Please send valid number of eth to buy NFT");
        vm.prank(buyer);
        marketplace.buyNFT{value: 0.8 ether}(address(collectionAddr), tokenId);
    }

    // Should revert if trying to buy an NFT that is not listed
    function test_shouldRevertWhenBuyingNonListedNFT() public {
        vm.expectRevert("NFT not listed!");
        vm.prank(buyer);
        marketplace.buyNFT(address(collectionAddr), 2);
    }

    // Should emit an NFTSold event upon successful purchase
    function test_shouldEmitNFTSoldEvent() public {
        vm.startPrank(seller);
        uint256 tokenId = collectionAddr.mint(seller, tokenURI);
        collectionAddr.approve(address(marketplace), tokenId);
        marketplace.listNFT(address(collectionAddr), tokenId, sellingPrice);
        vm.stopPrank();

        vm.deal(buyer, 2 ether);

        // Expect the NFTSold event to be emitted
        vm.expectEmit(true, true, true, true);
        emit NFTMarketplace.NFTSold(address(collectionAddr), tokenId, buyer, sellingPrice);

        vm.prank(buyer);
        marketplace.buyNFT{value: sellingPrice}(address(collectionAddr), tokenId);
    }
}
