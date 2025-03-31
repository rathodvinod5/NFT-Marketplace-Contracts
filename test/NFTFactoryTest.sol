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

    struct Collection {
        string name;
        string description;
        string image;
        address contractAddress;
        address creator;
    }

    function setUp() public {
        deployer = vm.addr(1);
        user1 = vm.addr(2);
        user2 = vm.addr(3);
        vm.prank(deployer);
        nftFactory = new NFTFactory();
    }

    // function test_createCollection() public {
    //     vm.startPrank(user1);
    //     vm.expectRevert("Only factory can create collections");
    //     new ERC721CollectionContract("Test Token", "TTKN");
    //     vm.stopPrank();
    // }


    // test whether collections are being generated csuccessfully
    function test_createCollectionSuccessfully() public {
        vm.startPrank(user1);
        address collectionAddress = nftFactory.createNewCollection("Test Token", "TTKN");
        assertTrue(collectionAddress != address(0));
        address paramAddress = nftFactory.getUserCollections(user1)[0].contractAddress;
        assertEq(paramAddress, collectionAddress);
        vm.stopPrank();
    }

    // Check if newly created collection is belongs to the correct user
    function test_collectionOwnership() public {
        vm.startPrank(user1);
        address collectionAddress = nftFactory.createNewCollection("Token", "TKN");
        assertTrue(collectionAddress != address(0));
        assertEq(Ownable(collectionAddress).owner(), user1);
    }

    // test whether the user is owner of the collection which he has created
    function test_checkCollectionOwner() public {
        vm.startPrank(user1);
        address collectionAddress = nftFactory.createNewCollection("Test Token", "TTKN");
        assertTrue(collectionAddress != address(0));
        address creator = nftFactory.getUserCollections(user1)[0].creator;
        assertEq(user1, creator);
        vm.stopPrank();
    }

    // Test if the collection list updates correctly when multiple collections are created by the same user
    function test_multipleCollectionsPerUser() public {
        vm.startPrank(user1);
        address collectionAddress1 = nftFactory.createNewCollection("Test Token1", "TKN1");
        assertTrue(collectionAddress1 != address(0));
        address paramAddress1 = nftFactory.getUserCollections(user1)[0].contractAddress;
        address collectionAddress2 = nftFactory.createNewCollection("Test Token2", "TKN2");
        assertTrue(collectionAddress2 != address(0));
        address paramAddress2 = nftFactory.getUserCollections(user1)[1].contractAddress;
        assertEq(collectionAddress1, paramAddress1);
        assertEq(collectionAddress2, paramAddress2);
    }

    // Test if collections are tracked correctly for different users
    function test_collectionsAreTrackedCorrecltyForUsers() public {
        vm.startPrank(user1);
        address collectionAddress = nftFactory.createNewCollection("Token1", "TKN1");
        assertTrue(collectionAddress != address(0));
        address user1CollectionAddress = nftFactory.getUserCollections(user1)[0].contractAddress;
        assertEq(collectionAddress, user1CollectionAddress);
        vm.stopPrank();

        vm.startPrank(user2);
        address collectionAddress1 = nftFactory.createNewCollection("Token1", "TKN1");
        assertTrue(collectionAddress1 != address(0));
        address user1CollectionAddress1 = nftFactory.getUserCollections(user2)[0].contractAddress;
        assertEq(collectionAddress1, user1CollectionAddress1);
        vm.stopPrank();
    }

    // Test if an invalid index access in getUserCollections reverts
    function test_getUserCollectionAtInvalidIndex() public {
        vm.startPrank(user1);
        address collection = nftFactory.createNewCollection("Token", "TKN");
        vm.stopPrank();

        vm.expectRevert();
        address collectionAddress = nftFactory.getUserCollectionAtIndex(user1, 2).contractAddress;
        // assertEq(invalidCollection, address(0), "Expected address(0) for invalid index");
    }
}