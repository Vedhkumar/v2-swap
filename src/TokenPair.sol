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

import {IERC20} from "./interfaces/IERC20.sol";
import {SwapERC20} from "./SwapERC20.sol";
/**
 * @title Token Pair contract
 * @author Vedh Kumar
 * @notice This contract acts as the pool for pair of tokens
 */

contract TokenPair is SwapERC20 {
    // errors
    error TokenPair__NotFactory();
    error TokenPair__InsufficientAmount();
    error TokenPair__InsufficientLiquidity();
    error TokenPair__InvalidInputAmount();

    // Type declarations
    address public s_factory;
    address public s_token0;
    address public s_token1;

    uint256 private s_reserve0;
    uint256 private s_reserve1;

    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;

    // State variables
    // Events
    // Modifiers
    // Functions
    // Layout of Functions:
    // constructor
    constructor() {
        s_factory = msg.sender;
    }

    // receive function (if exists)
    // fallback function (if exists)
    // external
    function initialize(address _token0, address _token1) external {
        require(msg.sender == s_factory, TokenPair__NotFactory());
        s_token0 = _token0;
        s_token1 = _token1;
    }

    function swap(uint256 _amount0Out, uint256 _amount1Out, address _to) external {
        require(_amount0Out >= 0 || _amount1Out >= 0, TokenPair__InsufficientAmount());

        (uint256 _reserve0, uint256 _reserve1) = getReserves();

        require(_amount0Out < _reserve0 && _amount1Out < _reserve1, TokenPair__InsufficientLiquidity());

        IERC20(s_token0).transferFrom(address(this), _to, _amount0Out);
        IERC20(s_token1).transferFrom(address(this), _to, _amount1Out);

        uint256 balance0 = IERC20(s_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(s_token1).balanceOf(address(this));

        uint256 amount0In = balance0 > _reserve0 - _amount0Out ? balance0 - (_reserve0 - _amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - _amount1Out ? balance1 - (_reserve1 - _amount1Out) : 0;

        require(amount0In > 0 || amount1In > 0, TokenPair__InvalidInputAmount());
    }

    function mint(address _to) external returns (uint256 liquidity) {
        (uint256 reserve0, uint256 reserve1) = getReserves();
        uint256 balance0 = IERC20(s_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(s_token1).balanceOf(address(this));

        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {
            liquidity = (amount0 * amount1 - MINIMUM_LIQUIDITY) ** 1 / 2;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            liquidity = amount0 * totalSupply / reserve0;
        }
        require(liquidity > 0, TokenPair__InsufficientLiquidity());
        _mint(_to, liquidity);
        _update(balance0, balance1);
    }

    function burn() external {}

    // public
    // internal
    function _update(uint256 _balance0, uint256 _balance1) internal {
        s_reserve0 = _balance0;
        s_reserve1 = _balance1;
    }
    // private
    // internal & private view & pure functions
    // external & public view & pure functions

    function getReserves() public view returns (uint256 reserve0, uint256 reserve1) {
        reserve0 = s_reserve0;
        reserve1 = s_reserve1;
    }
}
