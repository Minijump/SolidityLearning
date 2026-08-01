// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
// simple unit test to demonstrate how to use governor contract
import "forge-std/Test.sol";
import "../src/GovernorExample.sol";

contract GovernorExampleTest is Test {
    GovernorExample public governor;

    function setUp() public {
        governor = new GovernorExample();
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

    function testSetVotingDelayDirectCallFails() public {
        uint48 newVotingDelay = 2;
        vm.expectRevert();
        governor.setVotingDelay(newVotingDelay);
    }

    function testSetVotingDelayOnlyThroughGovernanceProposal() public {
        uint48 newVotingDelay = 2;
        address[] memory targets = new address[](1);
        targets[0] = address(governor);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeCall(GovernorSettings.setVotingDelay, (newVotingDelay));
        string memory description = "Set voting delay to 2 blocks";
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
}
