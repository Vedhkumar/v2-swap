// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Script} from "forge-std/Script.sol";
import {Router} from "src/swap/Router.sol";

contract CreatePool is Script {
    Router router;

    function run() external {
        router = getLatestRouter();
    }

    function getLatestRouter() internal returns (Router _router) {
        address contractAddress = DevOpsTools.get_most_recent_deployment("Router", block.chainid);
        _router = Router(contractAddress);
        return _router;
    }
}
