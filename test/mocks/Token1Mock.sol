// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Token1 is ERC20, Ownable {
    constructor(uint256 _amountToMint) ERC20("Token1", "TK1") Ownable(msg.sender) {
        mint(msg.sender, _amountToMint);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
