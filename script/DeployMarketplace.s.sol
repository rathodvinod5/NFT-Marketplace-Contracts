// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Marketplace.sol";

contract DeployMarketPlace is Script {
    function run() external {
        vm.startBroadcast();

        NFTMarketplace marketplace = new NFTMarketplace();

        console2.log("Marketplace contract Address: ", address(marketplace));

        vm.stopBroadcast();
    }
}