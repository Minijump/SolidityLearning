// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MyBurnableToken is ERC20, ERC20Burnable {
    constructor() ERC20("My Burnable Token", "MBTK") {
        _mint(msg.sender, 1000 ether);
    }
    // Public functions added are: 
    //      - burn(uint256 amount)
    //      - burnFrom(address account, uint256 amount)
}
