// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DaoIP} from "./DaoIP.sol";


contract Dao {
    // TODOs: 
    //  interface to use a DaoIP based (fctName(address))
    //  improve data strct (remove useless things; struct and mapping may be useless)
    struct Daoproposal{
        address proposalAddress;
        DaoIP proposal;
    }

    mapping(address => Daoproposal) public proposals;
    address[] public proposalList;

    function createProposal(string memory _name, string memory _description) public{
        DaoIP newProposal = new DaoIP(_name, _description);
        address proposalAddress = address(newProposal);
        proposals[proposalAddress] = Daoproposal(proposalAddress, newProposal);
        proposalList.push(proposalAddress);
    }
}
