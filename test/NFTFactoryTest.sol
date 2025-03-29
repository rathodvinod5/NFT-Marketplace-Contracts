// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/NFTFactory.sol";
import "../src/ERC721CollectionContract.sol";

contract NFTFactoryTest is Test {
    NFTFactory nftFactory;
    address deployer;
    address user1;
    address user2;

    function setUp() public {
        deployer = vm.addr(1);
        user1 = vm.addr(2);
        user2 = vm.addr(3);
        vm.prank(deployer);
        nftFactory = new NFTFactory();
    }

    function test_createCollection() public {
        vm.startPrank(user1);
        vm.expectRevert("Only factory can create collections");
        new ERC721CollectionContract("Test Token", "TTKN");
        vm.stopPrank();
    }

    function test_createCollectionSuccessfully() public {
        vm.startPrank(user1);
        address collectionAddress = nftFactory.createNewCollection("Test Token", "TTKN");
        assertTrue(collectionAddress != address(0));
        address paramAddress = nftFactory.getUserCollections(user1)[0].contractAddress;
        assertEq(paramAddress, collectionAddress);
        vm.stopPrank();
    }

    function test_multipleCollectionPerUser() public {
        vm.startPrank(user1);
        address deployedAddress1 = nftFactory.getUserCollections("Test Token1", "TKN1");
        address deployedAddress2 = nftFactory.getUserCollections("Test Token2", "TKN2");
        assertTrue(deployedAddress1 != address(0));
        assertTrue(deployedAddress2 != address(0));
        assertEq(nftFactory.getUserCollections(user1)[0].contractAddress, deployedAddress1);
        assertEq(nftFactory.getUserCollections(user1)[1].contractAddress, deployedAddress2);
    }
}