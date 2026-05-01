// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_UncheckedVault, ExerciseB_VulnerableVault} from "./Exercises.sol";

contract ArithmeticUncheckedExercisesStarterTest is Test {
    address internal victim = makeAddr("victim");

    function testExerciseA_writeExploit() external {
        ExerciseA_UncheckedVault vault = new ExerciseA_UncheckedVault();

        vm.deal(victim, 6 ether);
        vm.prank(victim);
        vault.deposit{value: 6 ether}();

        // TODO: build exploit that uses unchecked underflow to over-withdraw.
        // Suggested assertion target after success: address(vault).balance == 0.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableVault vault = new ExerciseB_VulnerableVault();

        vm.deal(victim, 6 ether);
        vm.prank(victim);
        vault.deposit{value: 6 ether}();

        // TODO: patch ExerciseB_VulnerableVault so underflow exploit fails.
        return;
    }
}
