// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {Factory} from "src/Factory.sol";
import {Router} from "src/Router.sol";

contract DeploySwap is Script {
    function run() external returns (Factory factory, Router router) {
        vm.startBroadcast();
        factory = deployFactory();
        router = deployRouter(factory);
        vm.stopBroadcast();
        console2.log("factory deployed at:", address(factory));
        console2.log("router deployed at:", address(router));
    }

    function deployFactory() internal returns (Factory factory) {
        factory = new Factory();
    }

    function deployRouter(Factory factory) internal returns (Router router) {
        router = new Router(address(factory));
    }
}
