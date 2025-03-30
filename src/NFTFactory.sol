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

    event CollectionCreated(string name, string description, address contractAddress, address creator);

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
}