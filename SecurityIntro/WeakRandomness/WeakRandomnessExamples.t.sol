// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableRandomGame,
    RandomnessPredictor,
    FixedCommitRevealGame
} from "./WeakRandomnessExamples.sol";

contract WeakRandomnessExamplesTest is Test {
    address internal player = makeAddr("player");

    function testPredictorWinsAgainstCurrentBlockRandomness() external {
        VulnerableRandomGame game = new VulnerableRandomGame();
        RandomnessPredictor attacker = new RandomnessPredictor(address(game));

        vm.deal(address(game), 5 ether);
        vm.deal(address(attacker), 1 ether);

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(attacker).balance, 2 ether);
    }

    function testCommitRevealSeparatesCommitFromOutcomeKnowledge() external {
        FixedCommitRevealGame game = new FixedCommitRevealGame();
        bytes32 salt = keccak256("lesson-1");
        bool guessEven = true;
        bytes32 commitment = keccak256(abi.encodePacked(guessEven, salt));

        vm.deal(address(game), 5 ether);
        vm.deal(player, 1 ether);

        vm.prank(player);
        game.commitBet{value: 1 ether}(commitment);

        uint256 commitBlock = block.number;

        vm.roll(block.number + 1);

        uint256 randomValue = uint256(keccak256(abi.encodePacked(blockhash(commitBlock), player, salt))) % 2;
        bool shouldWin = (randomValue == 0) == guessEven;

        vm.prank(player);
        game.reveal(guessEven, salt);

        if (shouldWin) {
            assertEq(player.balance, 2 ether);
            assertEq(address(game).balance, 4 ether);
        } else {
            assertEq(player.balance, 0);
            assertEq(address(game).balance, 6 ether);
        }
    }
}
