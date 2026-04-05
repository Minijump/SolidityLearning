// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {DaoFactory} from "../src/DaoFactory.sol";
import {Dao} from "../src/Dao.sol";
import {DaoIP} from "../src/DaoIP.sol";


contract DaoTest is Test {
    Dao dao;
    DaoIP proposal;
    address PROPOSER = makeAddr("proposer");
    address NON_PROPOSER = makeAddr("nonProposer");
    address NON_TOKEN_HOLDER = makeAddr("nonTokenHolder");

    function _initUser(address user, uint256 initialEthBalance, uint256 initialDaoTokenBalance) internal {
        vm.deal(user, initialEthBalance);
        if (initialDaoTokenBalance > 0) {
            vm.startPrank(address(this));
            dao.token().transfer(user, initialDaoTokenBalance);
            vm.stopPrank();
        }
    }

    function setUp() external {
        DaoFactory daoFactory = new DaoFactory();
        address daoAddress = daoFactory.createDao("TestDAO", "TST");
        dao = Dao(daoAddress);

        _initUser(PROPOSER, 100 ether, 10 ether);
        _initUser(NON_PROPOSER, 100 ether, 10 ether);
        _initUser(NON_TOKEN_HOLDER, 100 ether, 0);

        vm.startPrank(PROPOSER);
        proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        vm.stopPrank();
    }

    function testIsOpenFalseAfterDeadline() external {
        vm.warp(block.timestamp + 35 days);

        bool open = proposal.isOpen();

        assertFalse(open, "Proposal should be closed after deadline");
    }

    function testVote() external {
        vm.startPrank(PROPOSER);
        proposal.vote(DaoIP.Vote.Approve);
        vm.stopPrank();

        assertEq(uint8(proposal.votes(PROPOSER)), uint8(DaoIP.Vote.Approve), "Vote should be recorded as Approve");
        assertEq(proposal.voters(0), PROPOSER, "Voter should be recorded in voters array");
    }

    function testVoteByNonTokenHolder() external {
        vm.startPrank(NON_TOKEN_HOLDER);
        vm.expectRevert();
        proposal.vote(DaoIP.Vote.Approve);
        vm.stopPrank();
    }

    function testVoteClosedProposal() external {
        vm.startPrank(PROPOSER);
        vm.warp(block.timestamp + 35 days);

        vm.expectRevert();
        proposal.vote(DaoIP.Vote.Approve);
        vm.stopPrank();
    }

    function testVoteAlreadyVoted() external {
        vm.startPrank(PROPOSER);
        proposal.vote(DaoIP.Vote.Approve);

        vm.expectRevert();
        proposal.vote(DaoIP.Vote.Reject);
        vm.stopPrank();
    }

    function testCancelVote() external {
        vm.startPrank(PROPOSER);
        proposal.vote(DaoIP.Vote.Approve);

        proposal.cancelVote();

        assertEq(uint8(proposal.votes(PROPOSER)), uint8(DaoIP.Vote.Abstain), "Vote should be reset to Abstain");
        vm.stopPrank();
    }

    function testCancelVoteDidNotVote() external {
        vm.startPrank(PROPOSER);
        vm.expectRevert();
        proposal.cancelVote();
        vm.stopPrank();
    }

    function testCancelVoteClosedProposal() external {
        vm.startPrank(PROPOSER);
        vm.warp(block.timestamp + 35 days);

        vm.expectRevert();
        proposal.cancelVote();
        vm.stopPrank();
    }
}
