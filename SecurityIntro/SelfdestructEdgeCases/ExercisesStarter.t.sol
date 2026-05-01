// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_VulnerableBank, ExerciseA_ForceSender, ExerciseB_VulnerableBank} from "./Exercises.sol";

contract SelfdestructEdgeCasesExercisesStarterTest is Test {
    address internal alice = makeAddr("alice");

    function testExerciseA_writeExploit() external {
        ExerciseA_VulnerableBank bank = new ExerciseA_VulnerableBank();
        ExerciseA_ForceSender bomber = new ExerciseA_ForceSender{value: 1 wei}();

        vm.deal(alice, 1 ether);
        vm.prank(alice);
        bank.deposit{value: 1 ether}();

        // TODO: force-send ETH into bank and show withdraw path is broken.
        bomber;
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableBank bank = new ExerciseB_VulnerableBank();

        vm.deal(alice, 1 ether);
        vm.prank(alice);
        bank.deposit{value: 1 ether}();

        // TODO: patch ExerciseB_VulnerableBank so forced ETH does not break user withdrawals.
        bank;
        return;
    }
}
