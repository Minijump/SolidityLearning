// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DaoToken} from "./DaoToken.sol";
import {DaoIP} from "./DaoIP.sol";
import {Dex} from "./Dex.sol";


contract Dao {
    string public name;
    DaoToken public token;
    DaoIP[] public proposals;
    mapping (address => DaoIP) public daoIpMapping;
    Dex public dex;

    error NotTokenHolder();

    constructor(address _owner, string memory _name, string memory _symbol) {
        name = _name;
        token = new DaoToken(_owner, _name, _symbol, 21000000 ether);
        dex = new Dex(address(token));
    }

    modifier onlyTokenHolder() {
        _onlyTokenHolder();
        _;
    }

    function _onlyTokenHolder() internal view {
        if (token.balanceOf(msg.sender) == 0) {
            revert NotTokenHolder();
        }
    }

    function createProposal(string calldata _name, string calldata _description) public onlyTokenHolder returns (DaoIP) {
        DaoIP newProposal = new DaoIP(_name, _description, address(token), msg.sender);
        proposals.push(newProposal);
        daoIpMapping[address(newProposal)] = newProposal;
        return newProposal;
    }
}
