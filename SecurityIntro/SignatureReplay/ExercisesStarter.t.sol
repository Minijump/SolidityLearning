// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_VulnerableClaims, ExerciseB_VulnerableClaims} from "./Exercises.sol";

contract SignatureReplayExercisesStarterTest is Test {
    uint256 internal signerPk = 0xB0B;
    address internal signer = vm.addr(signerPk);
    address payable internal recipient = payable(makeAddr("recipient"));

    function testExerciseA_writeExploit() external {
        ExerciseA_VulnerableClaims claims = new ExerciseA_VulnerableClaims(signer);
        vm.deal(address(claims), 5 ether);

        // TODO: produce one valid signature and replay it.
        claims;
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_VulnerableClaims claims = new ExerciseB_VulnerableClaims(signer);
        vm.deal(address(claims), 5 ether);

        // TODO: patch ExerciseB_VulnerableClaims to enforce one-time signature usage.
        recipient;
        claims;
        return;
    }
}
