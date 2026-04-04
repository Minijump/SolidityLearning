// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DaoToken} from "./DaoToken.sol";
import {DaoIP} from "./DaoIP.sol";


contract Dao {
    string public name;
    string public symbol;
    DaoToken public token;
    DaoIP[] public proposals;
    mapping (address => DaoIP) public daoIpMapping;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        token = new DaoToken(msg.sender, _name, _symbol, 21000000 ether);
    }

    function createProposal(string memory _name, string memory _description) public{
        DaoIP newProposal = new DaoIP(_name, _description);
        proposals.push(newProposal);
        daoIpMapping[address(newProposal)] = newProposal;
    }

    // function approveProposal(address _proposalAddress) public{
    //     DaoIP proposal = proposals[_proposalAddress];
    //     proposal.vote(DaoIP.Vote.Approve);
    // }

    // function rejectProposal(address _proposalAddress) public{
    //     DaoIP proposal = proposals[_proposalAddress];
    //     proposal.vote(DaoIP.Vote.Reject);
    // }

    // function cancelVoteProposal(address _proposalAddress) public{
    //     DaoIP proposal = proposals[_proposalAddress];
    //     proposal.cancelVote();
    // }

    // function closeProposal(address _proposalAddress) public{
    //     DaoIP proposal = proposals[_proposalAddress];
    //     proposal.closeIP();
    // }

    // function getProposalResult(address _proposalAddress) public view returns (uint256, uint256){
    //     DaoIP proposal = proposals[_proposalAddress];
    //     return (proposal.getVotesResults());
    // }
}
