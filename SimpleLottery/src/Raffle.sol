// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error Raffle_NotEnoughETHEntered();

/**
 * @title raffle contract
 * @author me
 * @notice creates a raffle
 */
contract Raffle {
    uint256 private immutable iEntranceFee;

    constructor(uint256 entranceFee) {
        iEntranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value < iEntranceFee) {
            revert Raffle_NotEnoughETHEntered();
        }
        // TODO logic to enter the raffle
    }

    function getEntranceFee() public view returns (uint256) {
        return iEntranceFee;
    }
}
