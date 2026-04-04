//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DaoToken is ERC20 {
    constructor(address owner, string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }
}
