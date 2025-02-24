// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Factory} from "src/Factory.sol";
import {Router} from "src/Router.sol";

contract DeploySwap is Script {
    function run() external returns (Factory factory, Router router) {
        vm.startBroadcast();
        factory = deployFactory();
        router = deployRouter();
        vm.stopBroadcast();
    }

    function deployFactory() internal returns (Factory factory) {
        factory = new Factory();
    }

    function deployRouter() internal returns (Router router) {
        router = new Router();
    }
}
