// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Doge is ERC20 {
    error Doge__ZeroValue();

    constructor() ERC20("Doge TOKEN", "DGT") {
        _mint(msg.sender, 1000000000000000000000000000);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
