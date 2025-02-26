// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Trump is ERC20 {
    constructor() ERC20("Trump TOKEN", "TPT") {
        _mint(msg.sender, 1000000000000000000000000000);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
