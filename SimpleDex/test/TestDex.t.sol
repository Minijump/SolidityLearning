// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DEX} from "../src/DEX.sol";
import {DeployBalloonsDEX} from "../script/DeployBalloonsDex.s.sol";
import {Balloons} from "../src/Balloons.sol";


contract DEXTest is Test {
    DEX dex;
    Balloons balloons;
    address USER = makeAddr("user");

    function setUp() external {
        DeployBalloonsDEX deployer = new DeployBalloonsDEX();
        (dex, balloons) = deployer.run(address(this));

        balloons.transfer(USER, 100 ether);
        vm.startPrank(USER);
        balloons.approve(address(dex), 100 ether);
        vm.stopPrank();

        vm.deal(USER, 10000 ether);
    }

    function testInit() external {
        vm.startPrank(USER);
        uint256 initialLiquidity = dex.init{value: 100 ether}(100 ether);
        vm.stopPrank();

        assertEq(initialLiquidity, 100 ether);
        assertEq(dex.totalLiquidity(), 100 ether);
        assertEq(dex.getLiquidity(USER), 100 ether);
    }

    function testInitNotEnoughTokens() external {
        vm.startPrank(USER);
        vm.expectRevert();
        dex.init{value: 1000 ether}(1000 ether);
        vm.stopPrank();
    }

    function testInitNotEnoughEth() external {
        vm.startPrank(USER);
        vm.expectRevert();
        dex.init{value: 0}(100 ether);
        vm.stopPrank();
    }

    function testInitAlreadyInitialized() external {
        vm.startPrank(USER);
        dex.init{value: 100 ether}(100 ether);

        vm.expectRevert();
        dex.init{value: 100 ether}(100 ether);
        vm.stopPrank();
    }
}
