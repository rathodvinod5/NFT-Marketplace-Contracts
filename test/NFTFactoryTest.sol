// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/NFTFactory.sol";
import "../src/ERC721CollectionContract.sol";

contract NFTFactoryTest is Test {
    NFTFactory factory;
    address deployer;
    address user1;
    address user2;

    function setUp() public {
        deployer = vm.addr(1);
        user1 = vm.addr(2);
        user2 = vm.addr(3);
        vm.prank(deployer);
        factory = new NFTFactory();
    }

    function testOnlyFactoryCanCreateCollections() public {
        vm.startPrank(user1);
        vm.expectRevert("Only factory can create collections");
        new ERC721CollectionContract("Test Collection", "TST");
        vm.stopPrank();
    }
}