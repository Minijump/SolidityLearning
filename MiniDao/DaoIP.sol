// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

error AlreadyVoted();


contract DaoIP {
    // TODOs
    //  get_votes
    //  closeIP (only owners)
    string name;
    string description;
    address public immutable i_proposer;

    enum Vote { Abstain, Approve, Reject }
    mapping(address => Vote) public votes;
    uint256 votesCount = 0;
    uint256 approveCount = 0;
    address[] public voters;

    constructor(string memory _name, string memory _description) {
        name = _name;
        description = _description;
        i_proposer = msg.sender;
    }

    function vote(Vote _vote) external {
        if (votes[msg.sender] != Vote.Abstain){
            revert AlreadyVoted();
        }
        voters.push(msg.sender);
        votes[msg.sender] = _vote;
        if (_vote == Vote.Reject || _vote == Vote.Approve) {
            votesCount += 1;
        }
        if (_vote == Vote.Approve) {
            approveCount += 1;
        }
    }
}
