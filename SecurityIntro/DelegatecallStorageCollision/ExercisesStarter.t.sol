// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_Logic, ExerciseA_VulnerableProxy, ExerciseA_MaliciousLogic, ExerciseB_VulnerableProxy} from "./Exercises.sol";

contract DelegatecallStorageCollisionExercisesStarterTest is Test {
    address internal attacker = makeAddr("attacker");

    function testExerciseA_writeExploit() external {
        ExerciseA_Logic logic = new ExerciseA_Logic();
        ExerciseA_MaliciousLogic malicious = new ExerciseA_MaliciousLogic();
        ExerciseA_VulnerableProxy proxy = new ExerciseA_VulnerableProxy(address(logic));

        vm.deal(address(proxy), 3 ether);

        // TODO: exploit storage collision to set implementation to malicious and drain proxy funds.
        malicious;
        attacker;
        proxy;
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableProxy proxy = new ExerciseB_VulnerableProxy(address(new ExerciseA_Logic()));
        vm.deal(address(proxy), 3 ether);

        // TODO: patch ExerciseB_VulnerableProxy storage/upgrade model to prevent hijack.
        proxy;
        return;
    }
}
