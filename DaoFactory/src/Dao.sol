// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DaoToken} from "./DaoToken.sol";


contract Dao {
    string public name;
    string public symbol;
    DaoToken public token;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        token = new DaoToken(msg.sender, _name, _symbol, 21000000 ether);
    }
}
