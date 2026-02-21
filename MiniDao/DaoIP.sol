// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

error AlreadyVoted();
error DidNotVote();
error NotProposer();
error ClosedIP();

contract DaoIP {
    string name;
    string description;
    address public immutable i_proposer;
    bool isOpen = true;

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

    function vote(Vote _vote) external openIP{
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

    function cancelVote() external{
        if (votes[msg.sender] != Vote.Approve && votes[msg.sender] != Vote.Reject) {
            revert DidNotVote();
        }
        votes[msg.sender] = Vote.Abstain;
        votesCount -= 1;
    }

    function getVotesResults() public view returns (uint256, uint256) {
        return (approveCount, votesCount);
    }

    function closeIP() public onlyProposer openIP{
        isOpen = false;
    }
}
