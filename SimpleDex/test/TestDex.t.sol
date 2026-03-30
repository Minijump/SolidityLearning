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
    address USERWITHNOTOKENS = makeAddr("userWithNoTokens");
    address USERWITHNOTALLOWANCE = makeAddr("userWithNoAllowance");

    uint256 constant ACTION_AMOUNT = 1 ether;
    uint256 constant INIT_BALANCE_AMOUNT = 100 ether;

    function setUp() external {
        DeployBalloonsDEX deployer = new DeployBalloonsDEX();
        (dex, balloons) = deployer.run(address(this));

        _initUser(INITIALIZER, INIT_BALANCE_AMOUNT, INIT_BALANCE_AMOUNT, INIT_BALANCE_AMOUNT);
        _initUser(USER, INIT_BALANCE_AMOUNT, INIT_BALANCE_AMOUNT, INIT_BALANCE_AMOUNT);
        _initUser(USERWITHNOTOKENS, 0, INIT_BALANCE_AMOUNT, INIT_BALANCE_AMOUNT);
        _initUser(USERWITHNOTALLOWANCE, INIT_BALANCE_AMOUNT, 0, INIT_BALANCE_AMOUNT);
    }

    function _initUser(address user, uint256 balloonBalance, uint256 balloonAllowance, uint256 ethBalance) internal {
        if (balloonBalance > 0) {
            balloons.transfer(user, balloonBalance);
        }
        if (balloonAllowance > 0) {
            vm.startPrank(user);
            balloons.approve(address(dex), balloonAllowance);
            vm.stopPrank();
        }
        if (ethBalance > 0) {
            vm.deal(user, ethBalance);
        }
    }

    function testInit() external {
        vm.startPrank(INITIALIZER);
        uint256 initialLiquidity = dex.init{value: ACTION_AMOUNT}(ACTION_AMOUNT);
        vm.stopPrank();

        assertEq(initialLiquidity, ACTION_AMOUNT);
        assertEq(dex.totalLiquidity(), ACTION_AMOUNT);
        assertEq(dex.getLiquidity(INITIALIZER), ACTION_AMOUNT);
    }

    function testInitNotEnoughTokens() external {
        uint256 largeInitAmount = INIT_BALANCE_AMOUNT * 10;
        vm.deal(INITIALIZER, largeInitAmount);
        vm.startPrank(INITIALIZER);
        vm.expectRevert();
        dex.init{value: largeInitAmount}(largeInitAmount);
        vm.stopPrank();
    }

    function testTokenAmountMismatch() external {
        vm.startPrank(INITIALIZER);
        vm.expectRevert(abi.encodeWithSelector(DEX.AmountTokenEthMismatch.selector, ACTION_AMOUNT, 0));
        dex.init{value: 0}(ACTION_AMOUNT);
        vm.stopPrank();
    }

    function _initializeDex() internal {
        vm.startPrank(INITIALIZER);
        dex.init{value: ACTION_AMOUNT}(ACTION_AMOUNT);
        vm.stopPrank();
    }

    function testInitAlreadyInitialized() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DEX.DexAlreadyInitialized.selector));
        dex.init{value: ACTION_AMOUNT}(ACTION_AMOUNT);
        vm.stopPrank();
    }

    function testDeposit() external {
        _initializeDex();
        uint256 liquidityBeforeUser = dex.getLiquidity(USER);

        vm.startPrank(USER);
        uint256 tokenDeposit = dex.deposit{value: ACTION_AMOUNT}();
        vm.stopPrank();

        uint256 liquidityAfterUser = dex.getLiquidity(USER);
        assertEq(liquidityAfterUser, liquidityBeforeUser + ACTION_AMOUNT);
        assertEq(balloons.balanceOf(USER), INIT_BALANCE_AMOUNT - ACTION_AMOUNT - 1); // -1 wei due to rounding in deposit
        assertEq(tokenDeposit, ACTION_AMOUNT + 1); // deposit function adds +1 wei
    }

    function testDepositZeroEth() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DEX.InvalidEthAmount.selector));
        dex.deposit{value: 0}();
        vm.stopPrank();
    }

    function testDepositNotEnoughTokens() external {
        _initializeDex();

        vm.startPrank(USERWITHNOTOKENS);
        vm.expectRevert();
        dex.deposit{value: 1}();
        vm.stopPrank();
    }

    function testDepositNotEnoughAllowance() external {
        _initializeDex();

        vm.startPrank(USERWITHNOTALLOWANCE);
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
        (uint256 ethWithdrawn, uint256 tokensWithdrawn) = dex.withdraw(ACTION_AMOUNT);
        vm.stopPrank();

        uint256 liquidityAfter = dex.getLiquidity(INITIALIZER);
        assertEq(liquidityAfter, liquidityBefore - ACTION_AMOUNT);
        assertEq(address(INITIALIZER).balance, ethBalanceBefore + ethWithdrawn);
        assertEq(balloons.balanceOf(INITIALIZER), tokenBalanceBefore + tokensWithdrawn);
    }

    function testWithdrawNotEnoughLiquidity() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DEX.InsufficientLiquidity.selector, 0, 1 ether));
        dex.withdraw(1 ether);
        vm.stopPrank();
    }

    function testEthToToken() external {
        _initializeDex();
        uint256 tokenBalanceBefore = balloons.balanceOf(USER);
        uint256 ethBalanceBefore = address(USER).balance;
        uint256 ethReserve = address(dex).balance;
        uint256 tokenReserve = balloons.balanceOf(address(dex));
        uint256 expectedTokens = dex.price(ACTION_AMOUNT, ethReserve, tokenReserve);

        vm.startPrank(USER);
        uint256 tokensReceived = dex.ethToToken{value: ACTION_AMOUNT}();
        vm.stopPrank();

        assertEq(tokensReceived, expectedTokens);
        assertEq(balloons.balanceOf(USER), tokenBalanceBefore + tokensReceived);
        assertEq(address(USER).balance, ethBalanceBefore - ACTION_AMOUNT);
    }

    function testEthToTokenEmptyMessageValue() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DEX.InvalidEthAmount.selector));
        dex.ethToToken{value: 0}();
        vm.stopPrank();
    }

    function testTokenToEth() external {
        _initializeDex();
        uint256 tokenBalanceBefore = balloons.balanceOf(USER);
        uint256 ethBalanceBefore = address(USER).balance;
        uint256 tokenReserve = balloons.balanceOf(address(dex));
        uint256 ethReserve = address(dex).balance;
        uint256 expectedEth = dex.price(ACTION_AMOUNT, tokenReserve, ethReserve);

        vm.startPrank(USER);
        uint256 ethReceived = dex.tokenToEth(ACTION_AMOUNT);
        vm.stopPrank();

        assertEq(ethReceived, expectedEth);
        assertEq(balloons.balanceOf(USER), tokenBalanceBefore - ACTION_AMOUNT);
        assertEq(address(USER).balance, ethBalanceBefore + ethReceived);
    }

    function testTokenToEthNoTokenInMessage() external {
        _initializeDex();

        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(DEX.InvalidTokenAmount.selector));
        dex.tokenToEth(0);
        vm.stopPrank();
    }

    function testTokenToEthNotEnoughBalance() external {
        _initializeDex();

        vm.startPrank(USERWITHNOTOKENS);
        vm.expectRevert(abi.encodeWithSelector(DEX.InsufficientTokenBalance.selector, 0, 1));
        dex.tokenToEth(1);
        vm.stopPrank();
    }

    function testTokenToEthNotEnoughAllowance() external {
        _initializeDex();

        vm.startPrank(USERWITHNOTALLOWANCE);
        vm.expectRevert(abi.encodeWithSelector(DEX.InsufficientTokenAllowance.selector, 0, 1));
        dex.tokenToEth(1);
        vm.stopPrank();
    }

    function testPrice() external view{
        uint256 ethReserve = 100 ether;
        uint256 tokenReserve = 200 ether;
        uint256 inputAmount = 10 ether;
        uint256 inputAmountWithFee = inputAmount * 997; // accounting for 0.3% fee
        uint256 expectedOutput = (inputAmountWithFee * tokenReserve) / ((ethReserve*1000) + inputAmountWithFee);
        
        uint256 actualOutput = dex.price(inputAmount, ethReserve, tokenReserve);

        assertEq(actualOutput, expectedOutput);
    }
}
