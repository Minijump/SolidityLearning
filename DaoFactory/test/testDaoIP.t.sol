// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {DaoFactory} from "../src/DaoFactory.sol";
import {Dao} from "../src/Dao.sol";
import {DaoIP} from "../src/DaoIP.sol";


contract DaoTest is Test {
    Dao dao;
    address USER = makeAddr("user");

    function _initUser(address user, uint256 initialEthBalance) internal {
        vm.deal(user, initialEthBalance);
    }

    function setUp() external {
        DaoFactory daoFactory = new DaoFactory();
        _initUser(USER, 100 ether);
        vm.startPrank(USER);
        address daoAddress = daoFactory.createDao("TestDAO", "TST");
        vm.stopPrank();
        dao = Dao(daoAddress);
    }

    function testCloseProposal() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");

        proposal.close();

        assertFalse(proposal.isOpen(), "Proposal should be closed");
        vm.stopPrank();
    }

    function testCloseProposalByNonProposer() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        vm.stopPrank();
        address nonProposer = makeAddr("nonProposer");
        _initUser(nonProposer, 100 ether);

        vm.startPrank(nonProposer);
        vm.expectRevert();
        proposal.close();
        vm.stopPrank();
    }

    function testCloseAlreadyClosedProposal() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        proposal.close();

        vm.expectRevert();
        proposal.close();
        vm.stopPrank();
    }

    function testVote() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");

        proposal.vote(DaoIP.Vote.Approve);
        vm.stopPrank();

        assertEq(uint8(proposal.votes(USER)), uint8(DaoIP.Vote.Approve), "Vote should be recorded as Approve");
        assertEq(proposal.voters(0), USER, "Voter should be recorded in voters array");
    }

    function testVoteByNonTokenHolder() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        vm.stopPrank();
        address nonTokenHolder = makeAddr("nonTokenHolder");
        _initUser(nonTokenHolder, 100 ether);

        vm.startPrank(nonTokenHolder);
        vm.expectRevert();
        proposal.vote(DaoIP.Vote.Approve);
        vm.stopPrank();
    }

    function testVoteClosedProposal() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        proposal.close();

        vm.expectRevert();
        proposal.vote(DaoIP.Vote.Approve);
        vm.stopPrank();
    }

    function testVoteAlreadyVoted() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        proposal.vote(DaoIP.Vote.Approve);

        vm.expectRevert();
        proposal.vote(DaoIP.Vote.Reject);
        vm.stopPrank();
    }

    function testCancelVote() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        proposal.vote(DaoIP.Vote.Approve);

        proposal.cancelVote();

        assertEq(uint8(proposal.votes(USER)), uint8(DaoIP.Vote.Abstain), "Vote should be reset to Abstain");
        vm.stopPrank();
    }

    function testCancelVoteDidNotVote() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");

        vm.expectRevert();
        proposal.cancelVote();
        vm.stopPrank();
    }

    function testCancelVoteClosedProposal() external {
        vm.startPrank(USER);
        DaoIP proposal = dao.createProposal("Test Proposal", "This is a test proposal.");
        proposal.vote(DaoIP.Vote.Approve);
        proposal.close();

        vm.expectRevert();
        proposal.cancelVote();
        vm.stopPrank();
    }
}
