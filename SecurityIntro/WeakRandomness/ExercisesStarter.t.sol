// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_VulnerableGame, ExerciseB_VulnerableGame} from "./Exercises.sol";

contract WeakRandomnessExercisesStarterTest is Test {
    address internal player = makeAddr("player");

    function testExerciseA_writeExploit() external {
        ExerciseA_VulnerableGame game = new ExerciseA_VulnerableGame();

        vm.deal(address(game), 5 ether);
        vm.deal(player, 1 ether);

        // TODO: write predictor that computes same randomness and always wins.
        // Suggested assertion target after success: predictor profit > 0.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableGame game = new ExerciseB_VulnerableGame();

        vm.deal(address(game), 5 ether);
        vm.deal(player, 1 ether);

        // TODO: patch ExerciseB_VulnerableGame to commit/reveal or robust external RNG pattern.
        game;
        return;
    }
}
