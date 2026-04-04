// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { DaoToken } from "./DaoToken.sol";

error AlreadyVoted();
error DidNotVote();
error NotProposer();
error ClosedIP();

contract DaoIP {
    string public name;
    string public description;
    address public immutable i_proposer;
    bool public isOpen = true;
    DaoToken public daoToken;

    enum Vote { Abstain, Approve, Reject }
    mapping(address => Vote) public votes;
    address[] public voters;

    constructor(string memory _name, string memory _description, address _daoTokenAddress, address _proposer) {
        name = _name;
        description = _description;
        i_proposer = _proposer;
        daoToken = DaoToken(_daoTokenAddress);
    }

    modifier onlyTokenHolder() {
        require(daoToken.balanceOf(msg.sender) > 0, "Only token holders can perform this action");
        _;
    }

    modifier onlyProposer() {
        if (msg.sender != i_proposer){
            revert NotProposer();
        }
        _;
    }

    modifier openIP() {
        if (!isOpen){
            revert ClosedIP(); 
        }
        _;
    }

    function vote(Vote _vote) external onlyTokenHolder openIP{
        if (votes[msg.sender] != Vote.Abstain){
            revert AlreadyVoted();
        }
        voters.push(msg.sender);
        votes[msg.sender] = _vote;
    }

    function cancelVote() external openIP{
        if (votes[msg.sender] != Vote.Approve && votes[msg.sender] != Vote.Reject) {
            revert DidNotVote();
        }
        votes[msg.sender] = Vote.Abstain;
    }

    function close() public onlyProposer openIP{
        isOpen = false;
    }
}
