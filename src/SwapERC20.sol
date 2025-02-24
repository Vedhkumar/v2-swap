// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SwapERC20 is ERC20 {
    constructor() ERC20("SWAP TOKEN", "SPT") {}
}
