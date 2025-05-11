// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFTFactory.sol";
import "forge-std/console.sol";

contract DeployFactory is Script {
    function run() external {
        vm.startBroadcast();

        NFTFactory factory = new NFTFactory();

        console.log("Factory contract deployed at: ", address(factory));

        vm.stopBroadcast();
    }
}