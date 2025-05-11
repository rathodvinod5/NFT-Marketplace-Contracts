// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTFactory.sol";

contract DeployFactory is Script {
    function run() external {
        vm.startBroadcast();

        NFTFactory factory = new NFTFactory();

        console2.log("Factory contract Address: ", address(factory));

        vm.stopBroadcast();
    }
}