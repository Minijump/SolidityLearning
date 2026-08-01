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
}
