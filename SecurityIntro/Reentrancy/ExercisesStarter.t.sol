// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_ReentrancyVault, ExerciseB_VulnerableVault} from "./Exercises.sol";

contract ReentrancyExercisesStarterTest is Test {
    address internal alice = makeAddr("alice");

    function testExerciseA_writeExploit() external {
        ExerciseA_ReentrancyVault vault = new ExerciseA_ReentrancyVault();
        vm.deal(alice, 5 ether);

        vm.prank(alice);
        vault.deposit{value: 5 ether}();

        // TODO: deploy your exploit contract and drain the vault.
        // Suggested assertion target after success: address(vault).balance == 0.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableVault vault = new ExerciseB_VulnerableVault();
        vm.deal(alice, 5 ether);

        vm.prank(alice);
        vault.deposit{value: 5 ether}();

        // TODO: patch ExerciseB_VulnerableVault in Exercises.sol.
        // Then verify a reentrancy attacker can no longer drain this vault.
        return;
    }
}
