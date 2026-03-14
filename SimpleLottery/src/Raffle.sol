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
    address payable[] private sPlayers;

    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee) {
        iEntranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value < iEntranceFee) {
            revert Raffle_NotEnoughETHEntered();
        }
        sPlayers.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        return iEntranceFee;
    }
}
