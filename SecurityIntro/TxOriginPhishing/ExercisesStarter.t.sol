// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_TxOriginWallet, ExerciseB_VulnerableWallet} from "./Exercises.sol";

contract TxOriginExercisesStarterTest is Test {
    address internal owner = makeAddr("owner");
    address payable internal thief = payable(makeAddr("thief"));

    function testExerciseA_writeExploit() external {
        ExerciseA_TxOriginWallet wallet = new ExerciseA_TxOriginWallet(owner);

        vm.deal(owner, 3 ether);
        vm.prank(owner);
        (bool funded,) = address(wallet).call{value: 3 ether}("");
        require(funded, "fund failed");

        // TODO: deploy a phishing helper and trick owner into calling it.
        // Suggested assertion target after success: thief.balance == 3 ether.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableWallet wallet = new ExerciseB_VulnerableWallet(owner);
        vm.deal(owner, 3 ether);

        vm.prank(owner);
        (bool funded,) = address(wallet).call{value: 3 ether}("");
        require(funded, "fund failed");

        // TODO: patch ExerciseB_VulnerableWallet authorization.
        // Then verify phishing path fails and wallet retains funds.
        thief;
        return;
    }
}
