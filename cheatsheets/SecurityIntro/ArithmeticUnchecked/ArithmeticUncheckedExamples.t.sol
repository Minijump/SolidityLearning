// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableUncheckedVault,
    ArithmeticAttacker,
    FixedCheckedVault
} from "./ArithmeticUncheckedExamples.sol";

contract ArithmeticUncheckedExamplesTest is Test {
    address internal victim = makeAddr("victim");

    function setUp() external {
        vm.deal(victim, 10 ether);
    }

    function testUnderflowLetsAttackerDrainVault() external {
        VulnerableUncheckedVault vault = new VulnerableUncheckedVault();
        vm.prank(victim);
        vault.deposit{value: 5 ether}();
        ArithmeticAttacker attacker = new ArithmeticAttacker(address(vault));
        vm.deal(address(attacker), 1 ether);

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 0);
        assertEq(address(attacker).balance, 6 ether);
    }

    function testCheckedArithmeticStopsTheDrain() external {
        FixedCheckedVault vault = new FixedCheckedVault();
        vm.prank(victim);
        vault.deposit{value: 5 ether}();
        ArithmeticAttacker attacker = new ArithmeticAttacker(address(vault));
        vm.deal(address(attacker), 1 ether);

        vm.expectRevert();
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 5 ether);
    }
}
