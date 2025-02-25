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
    address alice = makeAddr("alice");

    function setUp() external {
        deploySwap = new DeploySwap();
        (factory, router) = deploySwap.run();
        token0 = new Token0(AMOUNTMINT);
        token1 = new Token1(AMOUNTMINT);
        setUpCaller = msg.sender;
        console2.log("address", alice);
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
        console2.log(Token0(token0).balanceOf(setUpCaller));
        factory.createPair(address(token0), address(token1));
        _;
    }

    ///Router///
    function testAddLiquidity() external createPool {
        address pair = SwapLibrary.pairFor(address(factory), address(token0), address(token1));
        uint256 initialLiquidity = TokenPair(pair).balanceOf(alice);
        console2.log(alice);

        Token0(token0).approve(address(router), AMOUNTMINT);
        Token1(token1).approve(address(router), AMOUNTMINT);
        router.addLiquidity(
            address(token0),
            address(token1),
            AMOUNTMINT,
            AMOUNTMINT,
            AMOUNTMINT - 1 ether,
            AMOUNTMINT - 1 ether,
            address(factory),
            alice
        );
        uint256 finalLiquidity = TokenPair(pair).balanceOf(alice);
        assert(initialLiquidity == 0);
        assert(finalLiquidity > 0);
    }
}
