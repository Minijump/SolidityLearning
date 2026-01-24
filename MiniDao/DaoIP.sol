// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


contract DaoIP {
    string name;
    string description;
    address public immutable i_proposer;

    constructor(string memory _name, string memory _description) {
        name = _name;
        description = _description;
        i_proposer = msg.sender;
    }
}
