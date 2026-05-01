// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_InitializableVault, ExerciseB_VulnerableVault} from "./Exercises.sol";

contract AccessControlMisconfigExercisesStarterTest is Test {
    address internal victim = makeAddr("victim");

    function testExerciseA_writeExploit() external {
        ExerciseA_InitializableVault vault = new ExerciseA_InitializableVault();

        vm.deal(victim, 4 ether);
        vm.prank(victim);
        vault.deposit{value: 4 ether}();

        // TODO: capture ownership via initialize and drain vault.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableVault vault = new ExerciseB_VulnerableVault();

        vm.deal(victim, 4 ether);
        vm.prank(victim);
        vault.deposit{value: 4 ether}();

        // TODO: patch initialization flow so attacker cannot become owner.
        vault;
        return;
    }
}
