// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {TokenPair} from "./TokenPair.sol";

library Library {
    error Library_InsufficientAmount();
    error Library_InvalidPath();

    function sortTokens(address _tokenA, address _tokenB) internal returns (address token0, address token1) {
        (token0, token1) = _tokenA > _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
    }

    function pairFor(address _factory, address _tokenA, address _tokenB) public pure returns (address pair) {
        (address _token0, address _token1) = sortTokens(_tokenA, _tokenB);
        bytes32 salt = keccak256(abi.encodePacked(_token0, _token1));
        bytes memory bytecode = type(TokenPair).creationCode;
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            _factory, // Factory contract address
                            salt,
                            keccak256(bytecode)
                        )
                    )
                )
            )
        );
    }

    function getAmountsOut(address _factory, uint256 _amountIn, address[] memory _path)
        external
        returns (uint256[] memory amounts)
    {
        require(_amountIn > 0, Library_InsufficientAmount());
        require(_path.length >= 2, Library_InvalidPath());
        amounts = new uint256[](_path.length);
        amounts[0] = _amountIn;
        for (uint256 i; i < _path.length; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(_factory, _path[i], _path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountOut(uint256 _amountIn, uint256 _reserveIn, uint256 _reserveOut)
        internal
        returns (uint256 amountOut)
    {
        ///@dev fee for this protocol is 0.3% i.e 0.003 times the amountIn
        uint256 amountInWithFee = _amountIn * 997;
        uint256 numerator = amountInWithFee * _reserveOut;
        uint256 denominator = _reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getReserves(address _factory, address _tokenA, address _tokenB)
        internal
        returns (uint256 reserveA, uint256 reserveB)
    {
        address pair = pairFor(_factory, _tokenA, _tokenB);
        (reserve0, reserve1) = TokenPair(pair).getReserves();
        (address token0,) = sortTokens(_tokenA, _tokenB);
        (reserveA, reserveB) = token0 == _tokenA ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint256 _amountA, uint256 _reserveA, uint256 _reserveB) external returns (uint256 amountB) {
        require(_amountA > 0, Library_InsufficientAmount());
        amountB = _amountA * _reserveB / _reserveA;
    }
}
