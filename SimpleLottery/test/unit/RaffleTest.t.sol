// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Raffle, Raffle__NotEnoughETHEntered} from "src/Raffle.sol";
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";

contract RaffleTest is Test {
    Raffle raffle;

    function setUp() public {
        DeployRaffle deployer = new DeployRaffle();
        raffle = deployer.run();
    }

    function testInitialState() public view {
        assertEq(uint256(raffle.getRaffleState()), uint256(Raffle.RaffleState.OPEN));
        assertEq(raffle.getNumberOfPlayers(), 0);
    }

    function testEnterRaffle() public {
        uint256 entranceFee = raffle.getEntranceFee();
        vm.prank(address(1));
        vm.deal(address(1), entranceFee);
        raffle.enterRaffle{value: entranceFee}();
        assertEq(raffle.getNumberOfPlayers(), 1);
        assertEq(raffle.getPlayer(0), address(1));
    }

    function testEnterRaffleNotEnoughETH() public {
        vm.prank(address(1));
        vm.deal(address(1), 0.01 ether);
        vm.expectRevert(Raffle__NotEnoughETHEntered.selector);
        raffle.enterRaffle{value: 0.01 ether}();
    }
}
