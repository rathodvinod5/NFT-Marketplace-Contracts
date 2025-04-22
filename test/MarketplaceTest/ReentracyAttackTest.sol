// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ERC721CollectionContract.sol";
import "../../src/Marketplace.sol";
import "./ReentracyAttack.sol";

contract ReentracyAttackTest is Test {
    ERC721CollectionContract collectionAddr;
    NFTMarketplace marketplace;
    ReentracyAttacker attacker;
    // uint tokenId;
    address seller;
    uint256 price = 1 ether;
    string tokenURI = "ipfs://QmTestHash1234567890abcdef";

    function setUp() public {
        seller = vm.addr(1);

        vm.startPrank(seller);
        collectionAddr = new ERC721CollectionContract("Token", "TKN", seller);
        marketplace = new NFTMarketplace();
        attacker = new ReentracyAttacker(address(collectionAddr), address(marketplace));
        vm.stopPrank();
    }

    function test_reentrancyProtectionOnBuy() public {
        vm.startPrank(seller);
        uint256 tokenId = collectionAddr.mint(seller, tokenURI);
        collectionAddr.approve(address(marketplace), tokenId);
        marketplace.listNFT(address(collectionAddr), tokenId, price);
        vm.stopPrank();

        vm.deal(address(attacker), price);
        vm.expectRevert();
        attacker.attackBuyNft{ value: price }(tokenId);
    }
}