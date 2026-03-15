// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Raffle, Raffle__NotEnoughETHEntered, Raffle__RaffleNotOpened, Raffle__NoteTimeToPickWinner} from "src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";


contract RaffleTest is Test {
    Raffle raffle;
    uint256 entranceFee = 0.1 ether;
    uint256 lowerEntranceFee = 0.01 ether;
    address player = address(1);

    function setUp() public {
        DeployRaffle deployer = new DeployRaffle();
        raffle = deployer.run(entranceFee, 30);
        vm.deal(player, entranceFee);
    }

    function testInitialState() public view {
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));
        assertEq(raffle.getNumberOfPlayers(), 0);
        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    function testEnterRaffle() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();

        assertEq(raffle.getNumberOfPlayers(), 1);
        assertEq(raffle.getPlayer(0), player);
    }

    function testEnterRaffleNotEnoughETH() public {
        vm.prank(address(1));
        vm.deal(address(1), lowerEntranceFee);
        vm.expectRevert(Raffle__NotEnoughETHEntered.selector);
        raffle.enterRaffle{value: lowerEntranceFee}();
    }

    function testPickWinnerNotTime() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();

        vm.expectRevert(Raffle__NoteTimeToPickWinner.selector);
        raffle.pickWinner();
    }

    function testPickWinner() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        uint256 playerStartingBalance = player.balance;

        vm.warp(block.timestamp + 31);
        raffle.pickWinner();

        assertEq(raffle.getNumberOfPlayers(), 0);
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));
        assertEq(player.balance, playerStartingBalance + entranceFee);
    }
}
