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
    string tokenURI1 = "ipfs://QmTestHash1234567890abcdef";
    string tokenURI2 = "ipfs://QmTestHash9876543210abcdef";
    string tokenURI3 = "ipfs://QmTestHash9876543210abcded";
    string tokenURI4 = "ipfs://QmTestHash9876543210abcdee";

    event CollectionCreated(string name, string description, address contractAddress, address creator);


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

    // Should store collection details correctly (name, address, creator)
    function test_shouldStoreCollectionDetailsCorreclty() public {
        vm.startPrank(user1);
        address collectionAdd = nftFactory.createNewCollection("Test Collection", "TTKN");
        assertTrue(collectionAdd != address(0));
        NFTFactory.Collection memory collection = nftFactory.getUserCollectionAtIndex(user1, 0);
        assertEq(collection.creator, user1);
        assertEq(collection.name, "Test Collection");
        assertEq(collection.symbol, "TTKN");
        vm.stopPrank();
    }

    // Check if newly created collection is belongs to the correct user
    function test_collectionOwnership() public {
        vm.startPrank(user1);
        address collectionAddress = nftFactory.createNewCollection("Token", "TKN");
        assertTrue(collectionAddress != address(0));
        assertEq(Ownable(collectionAddress).owner(), user1);
        vm.stopPrank();
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
        vm.stopPrank();
    }

    // Test if collections are tracked correctly for different users
    // Should handle multiple users creating collections without conflicts
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
    // Should revert if querying a collection that does not exist.
    function test_getUserCollectionAtInvalidIndex() public {
        vm.startPrank(user1);
        nftFactory.createNewCollection("Token", "TKN");
        vm.stopPrank();

        vm.expectRevert();
        nftFactory.getUserCollectionAtIndex(user1, 2).contractAddress;
        // assertEq(invalidCollection, address(0), "Expected address(0) for invalid index");
        vm.stopPrank();
    }

    function test_shouldTrackMintedNFTsInFactory() public {
        vm.startPrank(deployer);
        address collectionAdd = nftFactory.createNewCollection("Test Collection", "TKN");
        // collection = ERC721CollectionContract(collectionAddress);
        nftFactory.mintNFT(address(collectionAdd), tokenURI1);
        nftFactory.mintNFT(address(collectionAdd), tokenURI2);

        uint256[] memory collectionTokens = nftFactory.getCollectionTokens(collectionAdd);
        vm.stopPrank();

        assertEq(collectionTokens.length, 2, "Token length mismatch");
        assertEq(collectionTokens[0], 1, "Token length mismatch");
        assertEq(collectionTokens[1], 2, "Token length mismatch");
    }

    function test_shouldPreventUnauthorizedUsersFromMintingThroughFactory() public {
        vm.prank(user1);
        address collectionAdd = nftFactory.createNewCollection("Test Collection", "TKN");

        vm.startPrank(user2);
        vm.expectRevert("Not authorized");
        nftFactory.mintNFT(address(collectionAdd), tokenURI1);
        vm.stopPrank();
    }

    function test_shouldPreventMintingWithInvalidTokenURI() public {
        vm.prank(user1);
        address collectionAdd = nftFactory.createNewCollection("Test", "TKN");

        vm.expectRevert("Invalid token URI");
        nftFactory.mintNFT(collectionAdd, "");

        vm.expectRevert("Invalid token URI");
        nftFactory.mintNFT(collectionAdd, "invalid_uri");
    }

    // Should Allow Fetching Tokens from Multiple Collections Correctly
    // Should Ensure Correct Ownership Mapping When NFTs Are Minted
    function test_shouldAllowFetchingTokensFromMultipleCollectionsCorrectly() public {
        vm.startPrank(user1);
        address owner1Collection1 = nftFactory.createNewCollection("User1 Token", "TKN1");
        address owner1Collection2 = nftFactory.createNewCollection("User1 Token", "TKN2");
        vm.stopPrank();
        
        vm.prank(user2);
        address owner2Collection1 = nftFactory.createNewCollection("User2 Token", "TKN3");

        vm.startPrank(user1);
        nftFactory.mintNFT(address(owner1Collection1), tokenURI1);
        nftFactory.mintNFT(address(owner1Collection1), tokenURI2);
        vm.stopPrank();

        vm.prank(user2);
        nftFactory.mintNFT(address(owner2Collection1), tokenURI3);

        vm.prank(user1);
        nftFactory.mintNFT(address(owner1Collection2), tokenURI4);

        uint256[] memory user1Collection1Tokens = nftFactory.getCollectionTokens(owner1Collection1);
        uint256[] memory user1Collection2Tokens = nftFactory.getCollectionTokens(owner1Collection2);
        uint256[] memory user2Collection1Tokens = nftFactory.getCollectionTokens(owner2Collection1);

        // Should Allow Fetching Tokens from Multiple Collections Correctly
        assertEq(user1Collection1Tokens.length, 2, "Token length mismtach");
        assertEq(user1Collection1Tokens[0], 1, "Token id mismtach");
        assertEq(user1Collection1Tokens[1], 2, "Token id mismtach");

        assertEq(user1Collection2Tokens.length, 1, "Token length mismtach");
        assertEq(user1Collection2Tokens[0], 1, "Token id mismtach");

        assertEq(user2Collection1Tokens.length, 1, "Token length mismtach");
        assertEq(user2Collection1Tokens[0], 1, "Token id mismtach");


        // Should Ensure Correct Ownership Mapping When NFTs Are Minted
        assertEq(ERC721CollectionContract(owner1Collection1).ownerOf(user1Collection1Tokens[0]), user1);
        assertEq(ERC721CollectionContract(owner1Collection1).ownerOf(user1Collection1Tokens[1]), user1);
        assertEq(ERC721CollectionContract(owner1Collection2).ownerOf(user1Collection2Tokens[0]), user1);

        assertEq(ERC721CollectionContract(owner2Collection1).ownerOf(user2Collection1Tokens[0]), user2);
    }
}