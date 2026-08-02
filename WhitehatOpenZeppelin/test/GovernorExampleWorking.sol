// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
// simple unit test to demonstrate how to use governor contract
import "forge-std/Test.sol";
import "../src/GovernorExample.sol";

contract GovernorExampleTest is Test {
    GovernorExample public governor;
    address public ethOwner;
    address public noEtherOwner;
    uint48 newVotingDelay = 2;

    function setUp() public {
        governor = new GovernorExample();
        ethOwner = address(1);
        noEtherOwner = address(2);

        vm.deal(ethOwner, 1 ether);
        vm.deal(address(this), 1 ether); // Enable testing methods without using prank when not necessary
    }

    // check pure/view functions return the expected values
    function testVotingDelay() public view {
        assertEq(governor.votingDelay(), 1);
    }

    function testVotingPeriod() public view {
        assertEq(governor.votingPeriod(), 45818);
    }

    function testQuorum() public view {
        assertEq(governor.quorum(0), 4e18);
    }

    function testGetVotes() public view {
        assertEq(governor.getVotes(address(0), 0), 10e18);
    }

    // Test actions
    function _getProposalValues() internal view returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) {
        address[] memory proposalTargets = new address[](1);
        proposalTargets[0] = address(governor);
        uint256[] memory proposalValues = new uint256[](1);
        proposalValues[0] = 0;
        bytes[] memory proposalCalldatas = new bytes[](1);
        proposalCalldatas[0] = abi.encodeCall(GovernorSettings.setVotingDelay, (newVotingDelay));
        string memory proposalDescription = "Set voting delay to newVotingDelay blocks";

        return (proposalTargets, proposalValues, proposalCalldatas, proposalDescription);
    }

    function testSetVotingDelayDirectCallFails() public {
        vm.expectRevert();
        governor.setVotingDelay(newVotingDelay);
    }

    function testSetVotingDelayOnlyThroughGovernanceProposal() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();
        bytes32 descriptionHash = keccak256(bytes(description));

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // Move past snapshot so voting is active.
        vm.roll(block.number + governor.votingDelay() + 1);
        governor.castVote(proposalId, 1); // 1 = For
        // Move past deadline so proposal can be executed.
        vm.roll(block.number + governor.votingPeriod() + 1);
        governor.execute(targets, values, calldatas, descriptionHash);
        assertEq(governor.votingDelay(), newVotingDelay);
    }

    function testProposeMisc() public {
        address[] memory targets = new address[](1);
        targets[0] = address(0);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        string memory description = "Misc proposal";

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // check porposal state is active after voting delay
        vm.roll(block.number + governor.votingDelay() + 1);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Active));
    }

    function testVoteProposal() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // Move past snapshot so voting is active.
        vm.roll(block.number + governor.votingDelay() + 1);
        governor.castVote(proposalId, 1); // 1 = For

        // count votes
        assertEq(governor.hasVoted(proposalId, address(this)), true);
        (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) = governor.proposalVotes(proposalId);
        assertEq(againstVotes, 0);
        assertEq(forVotes, 50e18);
        assertEq(abstainVotes, 0);
    }

    function testAcceptedProposalIsExecuted() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();
        bytes32 descriptionHash = keccak256(bytes(description));
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // Move past snapshot so voting is active.
        vm.roll(block.number + governor.votingDelay() + 1);
        governor.castVote(proposalId, 1); // 1 = For

        // Move past deadline so proposal can be executed.
        vm.roll(block.number + governor.votingPeriod() + 1);
        governor.execute(targets, values, calldatas, descriptionHash);
        assertEq(governor.votingDelay(), newVotingDelay);
    }

    function testRefusedProposalIsNotExecuted() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();
        bytes32 descriptionHash = keccak256(bytes(description));
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // Move past snapshot so voting is active.
        vm.roll(block.number + governor.votingDelay() + 1);
        governor.castVote(proposalId, 0); // 0 = Against

        // Move past deadline so proposal can be executed.
        vm.roll(block.number + governor.votingPeriod() + 1);
        vm.expectRevert();
        governor.execute(targets, values, calldatas, descriptionHash);
    }

    function testMultipleVotesFromSameAccountFails() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + governor.votingDelay() + 1);
        governor.castVote(proposalId, 1);
        vm.expectRevert();
        governor.castVote(proposalId, 1);
    }

    function testInvalidVoteTypeFails() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + governor.votingDelay() + 1);
        vm.expectRevert();
        governor.castVote(proposalId, 3); // invalid vote type
    }

    function testMultipleAccountsVoting() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + governor.votingDelay() + 1);
        governor.castVote(proposalId, 1); // this account votes For
        vm.prank(address(99));
        governor.castVote(proposalId, 0); // another account votes Against
        vm.prank(address(100));
        governor.castVote(proposalId, 2); // another account votes Abstain
        vm.prank(address(101));
        governor.castVote(proposalId, 1); // another account votes For

        (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) = governor.proposalVotes(proposalId);
        assertEq(againstVotes, 10e18);
        assertEq(forVotes, 60e18);
        assertEq(abstainVotes, 10e18);
    }

    function testThresholdNotReachedReverts() public {
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description) = _getProposalValues();

        vm.expectRevert();
        vm.prank(noEtherOwner);
        governor.propose(targets, values, calldatas, description);
    }
}
