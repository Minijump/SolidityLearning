// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, 1000 ether);
    }
    // Public functions are: 
    //  - view: name(), symbol(), decimals(), totalSupply(), balanceOf(address account), allowance(address owner, address spender)
    //  - actions: - transfer(address to, uint256 amount) 
    //             - approve(address spender, uint256 amount)
    //             - transferFrom(address from, address to, uint256 amount)
}
