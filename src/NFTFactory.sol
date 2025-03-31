// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "./ERC721CollectionContract.sol";

contract NFTFactory {
    struct Collection {
        string name;
        string description;
        string image;
        address contractAddress;
        address creator;
    }

    Collection[] public collections;
    mapping(address => Collection[]) public userCollections;
    mapping(address => uint256[]) public collectionToTokens;

    event CollectionCreated(string name, string description, address contractAddress, address creator);
    event NFTMinted(address collectionAddress, address minter, uint256 tokenId);

    function createNewCollection(string memory name, string memory symbol) public returns(address) {
        ERC721CollectionContract contractAddress = new ERC721CollectionContract(name, symbol, msg.sender);
        Collection memory newCollection = Collection({
            name: name,
            description: "",
            image: "",
            contractAddress: address(contractAddress),
            creator: msg.sender
        });
        collections.push(newCollection);
        userCollections[msg.sender].push(newCollection);
        emit CollectionCreated(name, "", address(contractAddress), msg.sender);
        return address(contractAddress);
    }

    function mintNFT(address collectionAdd, string memory tokenURI) public {
        uint256 tokenId = ERC721CollectionContract(collectionAdd).mint(msg.sender, tokenURI);
        collectionToTokens[collectionAdd].push(tokenId);

        emit NFTMinted(collectionAdd, msg.sender, tokenId);
    }

    function getAllCollections() public view returns(Collection[] memory) {
        return collections;
    }

    function getUserCollections(address userAddress) public view returns(Collection[] memory) {
        return userCollections[userAddress];
    }

    function getUserCollectionAtIndex(address userAddress, uint256 index) public view returns(Collection memory) {
        require(index < userCollections[userAddress].length, "Invalid index");
        return userCollections[userAddress][index];
    }

    function getCollectionTokens(address collectionAdd) public view returns(uint256[] memory) {
        return collectionToTokens[collectionAdd];
    }
}