// Test Cases for NFTMarketplace Contract
// 1. Listing NFTs
// ✅ Should allow an NFT owner to list their NFT for sale.
// ✅ Should revert if the price is set to zero.
// ✅ Should revert if the sender is the zero address.
// ✅ Should revert if the NFT is already listed.
// ✅ Should revert if the caller is not the owner of the NFT.
// ✅ Should add the NFT to the listings mapping upon successful listing.
// ✅ Should add the NFT listing to allListings upon successful listing.
// ✅ Should add the NFT contract address to collectionsAddresses.

// 2. Buying NFTs
// ✅ Should allow a buyer to purchase a listed NFT.
// ✅ Should transfer the correct amount of ETH to the seller.
// ✅ Should revert if the sent ETH amount is less than the listed price.
// ✅ Should revert if trying to buy an NFT that is not listed.
// ✅ Should remove the NFT from the listings mapping after purchase.
// ✅ Should transfer ownership of the NFT to the buyer.
// ✅ Should emit an NFTSold event upon successful purchase.

// 3. Removing Listings
// ✅ Should allow the seller to remove their own NFT listing.
// ✅ Should revert if a non-seller tries to remove the listing.
// ✅ Should remove the listing from listings after successful removal.
// ✅ Should emit a ListingRemoved event upon successful removal.

// 4. Updating Listings
// ✅ Should allow the seller to update the price of their listed NFT.
// ✅ Should revert if a non-seller tries to update the listing.
// ✅ Should revert if the new price is set to zero.
// ✅ Should update the price in the listings mapping upon successful update.
// ✅ Should emit a ListingUpdated event upon successful price update.

// 5. Retrieving Listings & Collections
// ✅ Should return all listed NFTs using getAllListings().
// ✅ Should return all unique NFT contract addresses using getAllCollections().
// ✅ Should return an empty array if no listings exist.
// ✅ Should return an empty array if no collections exist.

// 6. Security & Edge Cases
// ✅ Should prevent reentrancy attacks on listing, buying, and updating.
// ✅ Should revert if trying to buy an NFT while it's being updated.
// ✅ Should revert if a seller tries to list an NFT they no longer own.
// ✅ Should ensure collectionsAddresses does not contain duplicate contract addresses.
// ✅ Should revert if seller is a smart contract that requires more than 2300 gas to accept ETH.
// ✅ Should successfully transfer ETH if the seller is an externally owned account (EOA).