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

import {Library} from "./Library.sol";
import {IFactory} from "./interfaces/IFactory.sol";

/**
 * @title Router contract
 * @author Vedh Kumar
 * @notice This contract acts as the pool for pair of tokens
 */
contract Router {
    // errors
    error Router__InsufficientOutputAmount();
    error Router__TransferFailed();
    error Router__IdenticalAddress();
    error Router__InsufficientAmount();

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

    //LIQUIDITY
    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _amountAMin,
        uint256 _amountBMin,
        address _factory
    ) external {}

    function removeLiquidity() external {}

    //SWAP
    function swapExactTokensForTokens(
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] memory _path,
        address _factory,
        address _to
    ) external {
        uint256[] amounts = Library.getAmountsOut(_amountIn, _path);
        require(amounts[amounts.length - 1] >= _amountOutMin, Router__InsufficientOutputAmount());
        (bool success,) = Library.pairFor(_factory, _path[0], _path[1]).call{value: amounts[0]}("");
        require(success, Router__TransferFailed());
        _swap(amounts, _path, _to);
    }

    function swapTokensForExactTokens() external {}

    // public
    // internal
    function _swap(uint256[] memory _amounts, address[] memory _path, address _to) internal {
        // [a,b,c,d] => [0,1,2,3]
        for (uint256 i; i < _amounts.length - 1; i++) {
            (address input, address output) = (_path[i], _path[i + 1]);
            (address token0,) = Library.sortTokens(input, output);
            (uint256 amount0Out, uint256 amount1Out) = token0 == input ? (0, _amounts[i + 1]) : (_amounts[i + 1], 0);
            address to = i == _amounts.length - 2 ? _to : Library.pairFor(_path[i + 1], _path[i + 2]);
            address pair = Library.pairFor(_path[i], _path[i + 1]);
            pair.swap(amount0Out, amount1Out, to);
        }
    }
    // private
    // internal & private view & pure functions

    function _addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _amountAMin,
        uint256 _amountBMin
    ) internal returns (uint256 amountA, uint256 amountB) {
        require(
            _amountA > 0 && _amountB > 0 && _amountADesired > 0 && _amountBDesired > 0, Router__InsufficientAmount()
        );

        if (IFactory(_factory).getPair(_tokenA, _tokenB) == address(0)) {
            pair = IFactory(_factory).createPair(_tokenA, _tokenB);
        }

        (uint256 reserveA, uint256 reserveB) = Library.getReserves(_factory, _tokenA, _tokenB);

        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (_amountADesired, _amountBDesired);
        } else {}
    }
    // external & public view & pure functions
}
