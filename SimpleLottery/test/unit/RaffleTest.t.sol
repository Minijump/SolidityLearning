// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Raffle, Raffle__NotEnoughETHEntered} from "src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";

contract RaffleTest is Test {
    Raffle raffle;
    uint256 entranceFee = 0.1 ether;
    uint256 lowerEntranceFee = 0.01 ether;

    function setUp() public {
        DeployRaffle deployer = new DeployRaffle();
        raffle = deployer.run(entranceFee, 30);
    }

    function testInitialState() public view {
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));
        assertEq(raffle.getNumberOfPlayers(), 0);
        assertEq(raffle.getEntranceFee(), entranceFee);
    }

    function testEnterRaffle() public {
        vm.prank(address(1));
        vm.deal(address(1), entranceFee);
        raffle.enterRaffle{value: entranceFee}();
        assertEq(raffle.getNumberOfPlayers(), 1);
        assertEq(raffle.getPlayer(0), address(1));
    }

    function testEnterRaffleNotEnoughETH() public {
        vm.prank(address(1));
        vm.deal(address(1), lowerEntranceFee);
        vm.expectRevert(Raffle__NotEnoughETHEntered.selector);
        raffle.enterRaffle{value: lowerEntranceFee}();
    }
}
