// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ERC721CollectionContract.sol";

contract ERC721CollectionContractTest is Test {
    ERC721CollectionContract collection;
    address owner = vm.addr(1);
    string constant tokenURI = "ipfs://QmTestHash1234567890abcdef";

    function setUp() public {
        vm.prank(owner);
        collection = new ERC721CollectionContract("Test Token", "TKN", owner);
    }

    function test_shouldAllowMintingNFT() public {
        vm.prank(owner);
        uint256 tokenId = collection.mint(owner, tokenURI);

        assertEq(collection.ownerOf(tokenId), owner, "Owner mismatch after minting");
        assertEq(collection.tokenURI(tokenId), tokenURI, "TokenURI mismatch after minting");
    }
}