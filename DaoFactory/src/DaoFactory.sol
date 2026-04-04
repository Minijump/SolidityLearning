// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Dao} from "./Dao.sol";


contract DaoFactory {
    function createDao(string memory _name, string memory _symbol) external returns (address) {
        Dao newDao = new Dao(msg.sender, _name, _symbol);
        return address(newDao);
    }
}
