// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DEX} from "../src/Dex.sol";
import {DeployBalloonsDEX} from "../script/DeployBalloonsDex.s.sol";
import {Balloons} from "../src/Balloons.sol";


contract DEXTest is Test {
    DEX dex;
    Balloons balloons;
    address INITIALIZER = makeAddr("initializer");
    address USER = makeAddr("user");

    function setUp() external {
        DeployBalloonsDEX deployer = new DeployBalloonsDEX();
        (dex, balloons) = deployer.run(address(this));

        balloons.transfer(INITIALIZER, 100 ether);
        balloons.transfer(USER, 100 ether);

        vm.startPrank(INITIALIZER);
        balloons.approve(address(dex), 100 ether);
        vm.stopPrank();
        vm.startPrank(USER);
        balloons.approve(address(dex), 100 ether);
        vm.stopPrank();

        vm.deal(INITIALIZER, 10000 ether);
        vm.deal(USER, 10000 ether);
    }

    function testInit() external {
        vm.startPrank(INITIALIZER);
        uint256 initialLiquidity = dex.init{value: 100 ether}(100 ether);
        vm.stopPrank();

        assertEq(initialLiquidity, 100 ether);
        assertEq(dex.totalLiquidity(), 100 ether);
        assertEq(dex.getLiquidity(INITIALIZER), 100 ether);
    }

    function testInitNotEnoughTokens() external {
        vm.startPrank(INITIALIZER);
        vm.expectRevert();
        dex.init{value: 1000 ether}(1000 ether);
        vm.stopPrank();
    }

    function testTokenAmountMismatch() external {
        vm.startPrank(INITIALIZER);
        vm.expectRevert();
        dex.init{value: 0}(100 ether);
        vm.stopPrank();
    }

    function _initializeDex() internal {
        vm.startPrank(INITIALIZER);
        dex.init{value: 100 ether}(100 ether);
        vm.stopPrank();
    }

    function testInitAlreadyInitialized() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert();
        dex.init{value: 100 ether}(100 ether);
        vm.stopPrank();
    }

    function testDeposit() external {
        _initializeDex();
        uint256 liquidityBeforeUser = dex.getLiquidity(USER);

        vm.startPrank(USER);
        uint256 tokenDeposit = dex.deposit{value: 10 ether}();
        vm.stopPrank();

        uint256 liquidityAfterUser = dex.getLiquidity(USER);
        assertEq(liquidityAfterUser, liquidityBeforeUser + 10 ether);
        assertEq(balloons.balanceOf(USER), 90 ether - 1); // -1 wei due to rounding in deposit
        assertEq(tokenDeposit, 10 ether + 1); // deposit function adds +1 wei
    }

    function testDepositZeroEth() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert();
        dex.deposit{value: 0}();
        vm.stopPrank();
    }

    function testDepositNotEnoughTokens() external {
        _initializeDex();
        address userWithNoTokens = makeAddr("userWithNoTokens");
        vm.deal(userWithNoTokens, 10000 ether);
        vm.startPrank(userWithNoTokens);
        balloons.approve(address(dex), 100 ether);
        vm.stopPrank();

        vm.startPrank(userWithNoTokens);
        vm.expectRevert();
        dex.deposit{value: 1}();
        vm.stopPrank();
    }

    function testDepositNotEnoughAllowance() external {
        _initializeDex();
        address userWithNoAllowance = makeAddr("userWithNoAllowance");
        vm.deal(userWithNoAllowance, 10000 ether);
        balloons.transfer(userWithNoAllowance, 100 ether);

        vm.startPrank(userWithNoAllowance);
        vm.expectRevert();
        dex.deposit{value: 1}();
        vm.stopPrank();
    }

    function testWithdraw() external {
        _initializeDex();
        uint256 liquidityBefore = dex.getLiquidity(INITIALIZER);
        uint256 tokenBalanceBefore = balloons.balanceOf(INITIALIZER);
        uint256 ethBalanceBefore = address(INITIALIZER).balance;

        vm.startPrank(INITIALIZER);
        (uint256 ethWithdrawn, uint256 tokensWithdrawn) = dex.withdraw(10 ether);
        vm.stopPrank();

        uint256 liquidityAfter = dex.getLiquidity(INITIALIZER);
        assertEq(liquidityAfter, liquidityBefore - 10 ether);
        assertEq(address(INITIALIZER).balance, ethBalanceBefore + ethWithdrawn);
        assertEq(balloons.balanceOf(INITIALIZER), tokenBalanceBefore + tokensWithdrawn);
    }

    function testWithdrawNotEnoughLiquidity() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert();
        dex.withdraw(1 ether);
        vm.stopPrank();
    }

    function testEthToToken() external {
        _initializeDex();
        uint256 tokenBalanceBefore = balloons.balanceOf(USER);
        uint256 ethBalanceBefore = address(USER).balance;

        vm.startPrank(USER);
        uint256 tokensReceived = dex.ethToToken{value: 10 ether}();
        vm.stopPrank();

        assertEq(balloons.balanceOf(USER), tokenBalanceBefore + tokensReceived);
        assertEq(address(USER).balance, ethBalanceBefore - 10 ether);
    }

    function testTokenToEth() external {
        _initializeDex();
        uint256 tokenBalanceBefore = balloons.balanceOf(USER);
        uint256 ethBalanceBefore = address(USER).balance;

        vm.startPrank(USER);
        uint256 ethReceived = dex.tokenToEth(10 ether);
        vm.stopPrank();

        assertEq(balloons.balanceOf(USER), tokenBalanceBefore - 10 ether);
        assertEq(address(USER).balance, ethBalanceBefore + ethReceived);
    }
}
