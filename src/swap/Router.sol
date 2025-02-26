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

import {SwapLibrary} from "src/SwapLibrary.sol";
import {IFactory} from "src/interfaces/IFactory.sol";
import {IERC20} from "src/interfaces/IERC20.sol";
import {TokenPair} from "./TokenPair.sol";

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
    error Router__ZeroLiquidity();
    error Router__InsufficientAmountLiquidity();
    error Router__InsufficientInputAmount();

    // Type declarations
    // State variables
    address public immutable i_factory;
    // Events
    // Modifiers
    // Functions
    // Layout of Functions:
    // constsructor

    constructor(address _factory) {
        i_factory = _factory;
    }
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
        address _factory,
        address _to
    ) external {
        (uint256 amountA, uint256 amountB) =
            _addLiquidity(_tokenA, _tokenB, _amountADesired, _amountBDesired, _amountAMin, _amountBMin, _factory);
        address pair = SwapLibrary.pairFor(_factory, _tokenA, _tokenB);
        IERC20(_tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(_tokenB).transferFrom(msg.sender, pair, amountB);
        TokenPair(pair).mint(_to);
    }

    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _liquidity, //? can a user with same liquidity in diffrent pair and remove tokens from anotoher pair using different liquidity tokens
        uint256 _amountAMin,
        uint256 _amountBMin,
        address _to
    ) external returns (uint256 amountA, uint256 amountB) {
        address pair = SwapLibrary.pairFor(i_factory, _tokenA, _tokenB);
        TokenPair(pair).transferFrom(msg.sender, pair, _liquidity);
        (uint256 amount0, uint256 amount1) = TokenPair(pair).burn(_to);
        (address token0,) = SwapLibrary.sortTokens(_tokenA, _tokenB);
        (amountA, amountB) = token0 == _tokenA ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= _amountAMin && amountB >= _amountBMin, Router__InsufficientAmountLiquidity());
    }

    //SWAP
    function swapExactTokensForTokens(
        uint256 _amountIn,
        uint256 _amountOutMin,
        address[] memory _path,
        address _factory,
        address _to
    ) external {
        uint256[] memory amounts = SwapLibrary.getAmountsOut(_factory, _amountIn, _path);
        require(amounts[amounts.length - 1] >= _amountOutMin, Router__InsufficientOutputAmount());
        (bool success,) = SwapLibrary.pairFor(_factory, _path[0], _path[1]).call{value: amounts[0]}("");
        require(success, Router__TransferFailed());
        _swap(amounts, _path, _to, _factory);
    }

    function swapTokensForExactTokens(
        uint256 _amountIn,
        uint256 _amountOutMax,
        address[] memory _path,
        address _factory,
        address _to
    ) external {
        uint256[] memory amounts = SwapLibrary.getAmountsIn(_factory, _amountOutMax, _path);
        require(amounts[0] >= _amountIn, Router__InsufficientInputAmount());
        (bool success,) = SwapLibrary.pairFor(_factory, _path[0], _path[1]).call{value: amounts[0]}("");
        require(success, Router__TransferFailed());
        _swap(amounts, _path, _to, _factory);
    }

    // public
    // internal
    function _swap(uint256[] memory _amounts, address[] memory _path, address _to, address _factory) internal {
        // [a,b,c,d] => [0,1,2,3]
        for (uint256 i; i < _amounts.length - 1; i++) {
            (address input, address output) = (_path[i], _path[i + 1]);
            (address token0,) = SwapLibrary.sortTokens(input, output);
            (uint256 amount0Out, uint256 amount1Out) =
                (token0 == input) ? (uint256(0), _amounts[i + 1]) : (_amounts[i + 1], uint256(0));
            address to = i == _amounts.length - 2 ? _to : SwapLibrary.pairFor(_factory, _path[i + 1], _path[i + 2]);
            address pair = SwapLibrary.pairFor(_factory, _path[i], _path[i + 1]);
            TokenPair(pair).swap(amount0Out, amount1Out, to);
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
        uint256 _amountBMin,
        address _factory
    ) internal returns (uint256 amountA, uint256 amountB) {
        require(
            _amountAMin > 0 && _amountBMin > 0 && _amountADesired > 0 && _amountBDesired > 0,
            Router__InsufficientAmount()
        );

        if (IFactory(_factory).getPair(_tokenA, _tokenB) == address(0)) {
            IFactory(_factory).createPair(_tokenA, _tokenB);
        }

        (uint256 reserveA, uint256 reserveB) = SwapLibrary.getReserves(_factory, _tokenA, _tokenB);

        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (_amountADesired, _amountBDesired);
        } else {
            uint256 amountBRequired = SwapLibrary.quote(_amountADesired, reserveA, reserveB);
            uint256 amountARequired = SwapLibrary.quote(_amountBDesired, reserveB, reserveA);

            if (amountBRequired >= _amountBMin && amountBRequired <= _amountBDesired) {
                (amountA, amountB) = (_amountADesired, amountBRequired);
            } else if (amountARequired >= _amountAMin && amountARequired <= _amountADesired) {
                (amountA, amountB) = (amountARequired, _amountBDesired);
            }
            // } else {
            //     revert(true, Router__InsufficientAmount());
            // }
        }
    }
    // external & public view & pure functions
}
