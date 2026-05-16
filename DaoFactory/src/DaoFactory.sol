// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Dao} from "./Dao.sol";


contract DaoFactory {
    function createDao(string calldata _name, string calldata _symbol) external returns (address) {
        Dao newDao = new Dao(msg.sender, _name, _symbol);
        return address(newDao);
    }
}
