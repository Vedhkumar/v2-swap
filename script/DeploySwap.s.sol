// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {Factory} from "src/swap/Factory.sol";
import {Router} from "src/swap/Router.sol";

import {Doge} from "src/tokens/Doge.sol";
import {Trump} from "src/tokens/Trump.sol";

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

contract DeployTokens is Script {
    Doge doge;
    Trump trump;

    function run() external returns (Doge, Trump) {
        vm.startBroadcast();
        doge = new Doge();
        trump = new Trump();
        vm.stopBroadcast();
        return (doge, trump);
    }
}
