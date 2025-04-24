// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.13;

import "./ERC721CollectionContract.sol";

contract NFTFactory {
    struct Collection {
        string name;
        string symbol;
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

    modifier isValidToken(string memory tokenURI) {
        require(bytes(tokenURI).length > 0, "Invalid token URI");
        _;
    }

    modifier isCollectionIndexValid(uint256 index, address userAddress) {
        require(index < userCollections[userAddress].length, "Invalid index");
        _;
    }

    function createNewCollection(string memory name, string memory symbol) public returns(address) {
        ERC721CollectionContract contractAddress = new ERC721CollectionContract(name, symbol, msg.sender);
        Collection memory newCollection = Collection({
            name: name,
            symbol: symbol,
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

    function mintNFT(address collectionAdd, string memory tokenURI) public isValidToken(tokenURI) {
        // require(bytes(tokenURI).length > 0, "Invalid token URI");
        require(isIPFS(tokenURI) || isHTTPS(tokenURI), "Invalid token URI");

        address owner = Ownable(collectionAdd).owner();
        require(msg.sender == owner, "Not authorized");

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

    function getUserCollectionAtIndex(address userAddress, uint256 index) public view 
        isCollectionIndexValid(index, userAddress) returns(Collection memory) {
        // require(index < userCollections[userAddress].length, "Invalid index");
        return userCollections[userAddress][index];
    }

    function getCollectionTokens(address collectionAdd) public view returns(uint256[] memory) {
        return collectionToTokens[collectionAdd];
    }

    function isIPFS(string memory _link) internal pure returns (bool) {
        bytes memory linkBytes = bytes(_link);
        if (linkBytes.length < 7) return false;
        return (
            linkBytes[0] == 'i' &&
            linkBytes[1] == 'p' &&
            linkBytes[2] == 'f' &&
            linkBytes[3] == 's' &&
            linkBytes[4] == ':' &&
            linkBytes[5] == '/' &&
            linkBytes[6] == '/'
        );
    }

    function isHTTPS(string memory _link) public pure returns (bool) {
        bytes memory linkBytes = bytes(_link);
        if (linkBytes.length < 8) return false;
        return (
            linkBytes[0] == 'h' &&
            linkBytes[1] == 't' &&
            linkBytes[2] == 't' &&
            linkBytes[3] == 'p' &&
            linkBytes[4] == 's' &&
            linkBytes[5] == ':' &&
            linkBytes[6] == '/' &&
            linkBytes[7] == '/'
        );
    }
}