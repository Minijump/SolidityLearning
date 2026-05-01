// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableUncheckedVault,
    ArithmeticAttacker,
    FixedCheckedVault,
    FailedArithmeticAttacker
} from "./ArithmeticUncheckedExamples.sol";

contract ArithmeticUncheckedExamplesTest is Test {
    address internal victim = makeAddr("victim");

    function testUnderflowLetsAttackerDrainVault() external {
        VulnerableUncheckedVault vault = new VulnerableUncheckedVault();
        ArithmeticAttacker attacker = new ArithmeticAttacker(address(vault));

        vm.deal(victim, 6 ether);
        vm.deal(address(attacker), 1 ether);

        vm.prank(victim);
        vault.deposit{value: 6 ether}();

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 0);
        assertEq(address(attacker).balance, 7 ether);
    }

    function testCheckedArithmeticStopsTheDrain() external {
        FixedCheckedVault vault = new FixedCheckedVault();
        FailedArithmeticAttacker attacker = new FailedArithmeticAttacker(address(vault));

        vm.deal(victim, 6 ether);
        vm.deal(address(attacker), 1 ether);

        vm.prank(victim);
        vault.deposit{value: 6 ether}();

        vm.expectRevert();
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 6 ether);
    }
}
