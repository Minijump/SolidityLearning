// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableSpotOracle,
    VulnerableLending,
    FixedTrustedOracle,
    FixedLending
} from "./OracleManipulationExamples.sol";

contract OracleManipulationExamplesTest is Test {
    address internal attacker = makeAddr("attacker");
    address internal owner = makeAddr("owner");

    function testManipulatedSpotPriceAllowsOverBorrow() external {
        VulnerableSpotOracle oracle = new VulnerableSpotOracle();
        VulnerableLending lending = new VulnerableLending(address(oracle));

        vm.deal(address(lending), 20 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(attacker);
        lending.depositCollateral{value: 1 ether}();

        vm.prank(attacker);
        oracle.setPrice(20000e18);

        vm.prank(attacker);
        lending.borrow(4 ether);

        assertEq(attacker.balance, 4 ether);
    }

    function testAttackerCannotManipulateTrustedOracle() external {
        FixedTrustedOracle oracle = new FixedTrustedOracle(owner);
        FixedLending lending = new FixedLending(address(oracle));

        vm.deal(address(lending), 20 ether);
        vm.deal(attacker, 1 ether);

        vm.prank(attacker);
        lending.depositCollateral{value: 1 ether}();

        vm.expectRevert();
        vm.prank(attacker);
        oracle.setPrice(20000e18);

        vm.expectRevert();
        vm.prank(attacker);
        lending.borrow(4 ether);
    }
}
