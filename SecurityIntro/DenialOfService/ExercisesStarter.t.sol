// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_VulnerableEscrow, ExerciseB_VulnerableEscrow} from "./Exercises.sol";

contract DenialOfServiceExercisesStarterTest is Test {
    address internal alice = makeAddr("alice");

    function testExerciseA_writeExploit() external {
        ExerciseA_VulnerableEscrow escrow = new ExerciseA_VulnerableEscrow();

        vm.deal(alice, 2 ether);
        vm.prank(alice);
        escrow.contribute{value: 2 ether}();

        // TODO: add malicious contributor that reverts on refund and blocks refundAll.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableEscrow escrow = new ExerciseB_VulnerableEscrow();

        vm.deal(alice, 2 ether);
        vm.prank(alice);
        escrow.contribute{value: 2 ether}();

        // TODO: patch ExerciseB_VulnerableEscrow to a pull-payment or equivalent safe design.
        return;
    }
}
