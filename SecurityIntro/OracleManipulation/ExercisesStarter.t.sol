// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_Oracle, ExerciseA_Lending, ExerciseB_VulnerableOracle, ExerciseB_VulnerableLending} from "./Exercises.sol";

contract OracleManipulationExercisesStarterTest is Test {
    address internal attacker = makeAddr("attacker");

    function testExerciseA_writeExploit() external {
        ExerciseA_Oracle oracle = new ExerciseA_Oracle();
        ExerciseA_Lending lending = new ExerciseA_Lending(address(oracle));

        vm.deal(address(lending), 20 ether);
        vm.deal(attacker, 1 ether);

        // TODO: manipulate oracle price then over-borrow against small collateral.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableOracle oracle = new ExerciseB_VulnerableOracle();
        ExerciseB_VulnerableLending lending = new ExerciseB_VulnerableLending(address(oracle));

        vm.deal(address(lending), 20 ether);
        vm.deal(attacker, 1 ether);

        // TODO: patch ExerciseB_VulnerableLending oracle usage to resist manipulation.
        oracle;
        lending;
        return;
    }
}
