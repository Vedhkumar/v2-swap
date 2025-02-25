// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constsructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {TokenPair} from "./TokenPair.sol";

/**
 * @title Facotry contract
 * @author Vedh Kumar
 * @notice This contract creates the token pair contracts and stores the addresses of the created token pairs
 */
contract Factory {
    // errors
    error Factory__IdenticalAddress();
    error Factory__ZeroAddress();
    error Factory__PairExists();
    error Factory__DeploymentFailed();
    // Type declarations
    // State variables

    mapping(address token0 => mapping(address token1 => address tokenPair))
        private s_getPair;

    // Events
    event TokenPairDeployed(address indexed tokenPair);

    // Modifiers
    // Functions

    // Layout of Functions:
    // constsructor
    constructor() {}

    // receive function (if exists)
    // fallback function (if exists)
    // external
    function createPair(
        address _tokenA,
        address _tokenB
    ) external returns (address pair) {
        require(_tokenA != _tokenB, Factory__IdenticalAddress());
        ///@dev since we have checked above that _tokenA != _tokenB, it is ok to check anyone token to zero address
        require(_tokenA != address(0), Factory__ZeroAddress());
        (address token0, address token1) = _tokenA > _tokenB
            ? (_tokenA, _tokenB)
            : (_tokenB, _tokenA);
        require(s_getPair[token0][token1] == address(0), Factory__PairExists());

        bytes memory bytecode = type(TokenPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        require(pair != address(0), Factory__DeploymentFailed());
        TokenPair(pair).initialize(token0, token1);
        s_getPair[token0][token1] = pair;
        emit TokenPairDeployed(pair);
    }

    // public
    // internal
    // private
    // internal & private view & pure functions
    // external & public view & pure functions

    function getPair(
        address _tokenA,
        address _tokenB
    ) external view returns (address pair) {
        (address token0, address token1) = _tokenA > _tokenB
            ? (_tokenA, _tokenB)
            : (_tokenB, _tokenA);
        pair = s_getPair[token0][token1];
    }
}
