// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableCoinFlipGame,
    RandomnessPredictorAttacker
} from "./WeakRandomnessExamples.sol";

contract WeakRandomnessExamplesTest is Test {
    address internal player = makeAddr("player");

    function testPredictorWinsAgainstCurrentBlockRandomness() external {
        VulnerableCoinFlipGame game = new VulnerableCoinFlipGame();
        vm.deal(address(game), 5 ether);
        RandomnessPredictorAttacker attacker = new RandomnessPredictorAttacker(address(game));
        vm.deal(address(attacker), 1 ether);

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(attacker).balance, 2 ether);
    }
}
