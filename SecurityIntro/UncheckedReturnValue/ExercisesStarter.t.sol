// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ExerciseA_AlwaysFalseToken, ExerciseA_VulnerableShop, ExerciseB_AlwaysFalseToken, ExerciseB_VulnerableShop} from "./Exercises.sol";

contract UncheckedReturnValueExercisesStarterTest is Test {
    address internal buyer = makeAddr("buyer");
    address internal treasury = makeAddr("treasury");

    function testExerciseA_writeExploit() external {
        ExerciseA_AlwaysFalseToken token = new ExerciseA_AlwaysFalseToken();
        ExerciseA_VulnerableShop shop = new ExerciseA_VulnerableShop(address(token), treasury);

        vm.prank(buyer);
        shop.buy();

        // TODO: assert exploit outcome explicitly and extend with a second variant.
        return;
    }

    function testExerciseB_writeFix() external {
        ExerciseB_AlwaysFalseToken token = new ExerciseB_AlwaysFalseToken();
        ExerciseB_VulnerableShop shop = new ExerciseB_VulnerableShop(address(token), treasury);

        // TODO: patch ExerciseB_VulnerableShop to reject failed token payments.
        buyer;
        shop;
        return;
    }
}
