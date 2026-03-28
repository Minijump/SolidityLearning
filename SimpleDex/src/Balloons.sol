//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Balloons is ERC20 {
    constructor(address owner) ERC20("Balloons", "BAL") {
        _mint(owner, 1000 ether); // mints 1000 balloons!
    }
}
