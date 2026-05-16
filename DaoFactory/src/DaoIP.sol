// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { DaoToken } from "./DaoToken.sol";

error AlreadyVoted();
error DidNotVote();
error DeadlineNotReached();
error ClosedIP();
error NotTokenHolder();

contract DaoIP {
    string public name;
    string public description;
    address public immutable i_proposer;
    uint256 public immutable i_deadline;
    DaoToken public daoToken;

    enum Vote { Abstain, Approve, Reject }
    mapping(address => Vote) public votes;
    address[] public voters;

    constructor(string memory _name, string memory _description, address _daoTokenAddress, address _proposer) {
        name = _name;
        description = _description;
        i_proposer = _proposer;
        i_deadline = block.timestamp + 30 days;
        daoToken = DaoToken(_daoTokenAddress);
    }

    modifier onlyTokenHolder() {
        _onlyTokenHolder(msg.sender);
        _;
    }

    function _onlyTokenHolder(address user) internal view {
        if (daoToken.balanceOf(user) == 0) {
            revert NotTokenHolder();
        }
    }

    modifier openIP() {
        _openIP();
        _;
    }

    function _openIP() internal view {
        if (!isOpen()) {
            revert ClosedIP();
        }
    }

    function isOpen() public view returns (bool) {
        return block.timestamp < i_deadline;
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

    function getResults() external view returns (uint256 approveCount, uint256 rejectCount, uint256 abstainCount) {
        uint256 totalVotes = voters.length;
        for (uint256 i = 0; i < totalVotes; i++) {
            address voter = voters[i];
            Vote voterVote = votes[voter];
            if (voterVote == Vote.Approve) {
                approveCount += daoToken.balanceOf(voter);
            } else if (voterVote == Vote.Reject) {
                rejectCount += daoToken.balanceOf(voter);
            } else {
                abstainCount += daoToken.balanceOf(voter);
            }
        }
        return (approveCount, rejectCount, abstainCount);
    }
}
