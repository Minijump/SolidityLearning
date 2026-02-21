// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DaoIP} from "./DaoIP.sol";


contract Dao {
    mapping(address => DaoIP) public proposals;
    address[] public proposalList;

    function createProposal(string memory _name, string memory _description) public{
        DaoIP newProposal = new DaoIP(_name, _description);
        address proposalAddress = address(newProposal);
        proposals[proposalAddress] = newProposal;
        proposalList.push(proposalAddress);
    }

    function approveProposal(address _proposalAddress) public{
        DaoIP proposal = proposals[_proposalAddress];
        proposal.vote(DaoIP.Vote.Approve);
    }

    function rejectProposal(address _proposalAddress) public{
        DaoIP proposal = proposals[_proposalAddress];
        proposal.vote(DaoIP.Vote.Reject);
    }

    function closeProposal(address _proposalAddress) public{
        DaoIP proposal = proposals[_proposalAddress];
        proposal.closeIP();
    }

    function getProposalResult(address _proposalAddress) public view returns (uint256, uint256){
        DaoIP proposal = proposals[_proposalAddress];
        return (proposal.getVotesResults());
    }
}
