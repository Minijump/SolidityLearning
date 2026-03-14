// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error Raffle__NotEnoughETHEntered();
error Raffle__NoteTimeToPickWinner();
error Raffle__TransferFailed();
error Raffle__RaffleNotOpened();

/**
 * @title raffle contract
 * @author me
 * @notice creates a raffle
 */
contract Raffle {
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint256 private immutable iEntranceFee;
    uint256 private immutable iInterval; //duration in seconds
    uint256 private sLastTimeStamp;
    address payable[] private sPlayers;
    RaffleState private sRaffleState;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(uint256 entranceFee, uint256 interval) {
        iEntranceFee = entranceFee;
        iInterval = interval;
        sLastTimeStamp = block.timestamp;
        sRaffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < iEntranceFee) {
            revert Raffle__NotEnoughETHEntered();
        }
        if (sRaffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpened();
        }
        sPlayers.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // CEI: Checks, Effects, Interactions
    function pickWinner() external {
        if((block.timestamp - sLastTimeStamp) < iInterval) {
            revert Raffle__NoteTimeToPickWinner();
        }
        if (sRaffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpened();
        }

        sRaffleState = RaffleState.CALCULATING;
        uint256 randomNumber = 2; // for testing purposes, else use chainlink VRF
        uint256 winnerIndex = randomNumber % sPlayers.length;
        address payable winner = sPlayers[winnerIndex];
        sPlayers = new address payable[](0);
        sLastTimeStamp = block.timestamp;
        sRaffleState = RaffleState.OPEN;
        emit WinnerPicked(winner);
    
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    function getEntranceFee() external view returns (uint256) {
        return iEntranceFee;
    }
}
