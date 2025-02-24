// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {DeploySwap} from "script/DeploySwap.s.sol";
import {Router} from "src/Router.sol";
import {Factory} from "src/Factory.sol";
import {TokenPair} from "src/TokenPair.sol";
import {SwapLibrary} from "src/SwapLibrary.sol";
import {Token0} from "../mocks/Token0Mock.sol";
import {Token1} from "../mocks/Token1Mock.sol";

contract SwapTest is Test {
    Router router;
    Factory factory;
    DeploySwap deploySwap;

    Token0 token0;
    Token1 token1;
    uint256 constant AMOUNTMINT = 10000 ether;

    address setUpCaller;

    function setUp() external {
        deploySwap = new DeploySwap();
        (factory, router) = deploySwap.run();
        token0 = new Token0(AMOUNTMINT);
        token1 = new Token1(AMOUNTMINT);
        setUpCaller = msg.sender;
    }

    ///Factory///
    function testGetPair() public view {
        address pair = factory.getPair(address(7), address(1));
        console2.log("address", pair);
    }

    function testRevertForSameToken() public {
        vm.expectRevert(Factory.Factory__IdenticalAddress.selector);
        factory.createPair(address(token0), address(token0));
    }

    function testRevertForAddressZero() public {
        vm.expectRevert(Factory.Factory__ZeroAddress.selector);
        factory.createPair(address(0), address(token0));
    }

    function testCreatePairFactory() public {
        factory.createPair(address(token0), address(token1));
        address pair = factory.getPair(address(token0), address(token1));
        assert(pair != address(0));
    }

    function testEmitOnPairCreation() public {
        address pair = SwapLibrary.pairFor(address(factory), address(token0), address(token1));
        vm.expectEmit(true, false, false, false, address(factory));
        emit Factory.TokenPairDeployed(pair);
        factory.createPair(address(token0), address(token1));
    }

    modifier createPool() {
        factory.createPair(address(token0), address(token1));
        _;
    }
    ///Router///
}
