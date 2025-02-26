// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {TokenPair} from "src/swap/TokenPair.sol";

library SwapLibrary {
    error Library_InsufficientAmount();
    error Library_InvalidPath();
    error Library__NoReserves();

    function sortTokens(address _tokenA, address _tokenB) internal pure returns (address token0, address token1) {
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
        view
        returns (uint256[] memory amounts)
    {
        require(_amountIn > 0, Library_InsufficientAmount());
        require(_path.length >= 2, Library_InvalidPath());
        amounts = new uint256[](_path.length);
        amounts[0] = _amountIn;
        for (uint256 i; i < _path.length; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(_factory, _path[i], _path[i + 1]);
            require(reserveIn > 0 && reserveOut > 0, Library__NoReserves());
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountOut(uint256 _amountIn, uint256 _reserveIn, uint256 _reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        ///@dev fee for this protocol is 0.3% i.e 0.003 times the amountIn
        uint256 amountInWithFee = _amountIn * 997;
        uint256 numerator = amountInWithFee * _reserveOut;
        uint256 denominator = _reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function getAmountsIn(address _factory, uint256 _amountOut, address[] memory _path)
        external
        view
        returns (uint256[] memory amounts)
    {
        amounts = new uint256[](_path.length);
        amounts[_path.length - 1] = _amountOut;
        for (uint256 i = _path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(_factory, _path[i - 1], _path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountIn(uint256 _amountOut, uint256 _reserveIn, uint256 _reserveOut)
        internal
        pure
        returns (uint256 amountIn)
    {
        uint256 numerator = _reserveIn * _amountOut * 1000;
        uint256 denominator = (_reserveOut - _amountOut) * 997;
        amountIn = (numerator / denominator) + 1;
    }

    function getReserves(address _factory, address _tokenA, address _tokenB)
        internal
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        address pair = pairFor(_factory, _tokenA, _tokenB);
        (uint256 reserve0, uint256 reserve1) = TokenPair(pair).getReserves();
        (address token0,) = sortTokens(_tokenA, _tokenB);
        (reserveA, reserveB) = token0 == _tokenA ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint256 _amountA, uint256 _reserveA, uint256 _reserveB) external pure returns (uint256 amountB) {
        require(_amountA > 0, Library_InsufficientAmount());
        amountB = _amountA * _reserveB / _reserveA;
    }
}
