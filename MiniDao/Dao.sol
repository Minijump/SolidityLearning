// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DaoIP} from "./DaoIP.sol";


contract Dao {
    // TODOs: 
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

    function approveProposal(address _proposalAddress) public{
        DaoIP proposal = proposals[_proposalAddress].proposal;
        proposal.vote(DaoIP.Vote.Approve);
    }

    function rejectProposal(address _proposalAddress) public{
        DaoIP proposal = proposals[_proposalAddress].proposal;
        proposal.vote(DaoIP.Vote.Reject);
    }
}
