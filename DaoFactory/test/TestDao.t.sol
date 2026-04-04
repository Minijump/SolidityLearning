// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {DaoFactory} from "../src/DaoFactory.sol";
import {Dao} from "../src/Dao.sol";
import {DaoIP} from "../src/DaoIP.sol";


contract DaoFactoryTest is Test {
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

    function testCreateProposal() external {
        vm.startPrank(USER);
        dao.createProposal("Test Proposal", "This is a test proposal.");
        vm.stopPrank();

        DaoIP proposal = dao.proposals(0);
        assertEq(proposal.name(), "Test Proposal", "Proposal name should be 'Test Proposal'");
        assertEq(proposal.description(), "This is a test proposal.", "Proposal description should be 'This is a test proposal.'");
        assertEq(address(dao.daoIpMapping(address(proposal))), address(proposal), "Proposal should be correctly mapped in daoIpMapping");
    }

    function testCreateProposalWithoutTokens() external {
        address nonTokenHolder = makeAddr("nonTokenHolder");
        _initUser(nonTokenHolder, 100 ether);
        vm.startPrank(nonTokenHolder);
        vm.expectRevert("Only token holders can perform this action");
        dao.createProposal("Test Proposal", "This is a test proposal.");
        vm.stopPrank();
    }
}
