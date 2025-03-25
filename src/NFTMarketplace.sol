// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

contract NFTMarkeplace {
    struct Collection {
        string name;
        string description;
        string image;
        address contractAddress;
        address creator;
    }

    Collection[] public collections;
    mapping(address => Collection[]) public userCollections;

    function createNewCollection(string memory name, string memory symbol) public {
        
    }

    function getAllCollections() public view returns(Collection[] memory) {
        return collections;
    }

    function getUserCollections(address userAddress) public view returns(Collection[] memory) {
        return userCollections[userAddress];
    }
}