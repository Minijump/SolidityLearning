// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {DaoFactory} from "../src/DaoFactory.sol";
import {Dao} from "../src/Dao.sol";
import {DaoIP} from "../src/DaoIP.sol";
import {Dex} from "../src/Dex.sol";


contract DaoTest is Test {
    Dao dao;
    Dex dex;

    address TOKEN_HOLDER = makeAddr("tokenHolder");
    address NON_TOKEN_HOLDER = makeAddr("nonTokenHolder");
    address NO_ALLOWANCE_TOKEN_HOLDER = makeAddr("noAllowanceTokenHolder");

    function _initUser(address user, uint256 initialEthBalance, uint256 initialDaoTokenBalance, uint256 initialDexAllowance) internal {
        vm.deal(user, initialEthBalance);
        if (initialDaoTokenBalance > 0) {
            vm.startPrank(address(this));
            dao.token().transfer(user, initialDaoTokenBalance);
            vm.stopPrank();
        }
        if (initialDexAllowance > 0) {
            vm.startPrank(user);
            dao.token().approve(address(dex), initialDexAllowance);
            vm.stopPrank();
        }
    }

    function setUp() external {
        DaoFactory daoFactory = new DaoFactory();
        address daoAddress = daoFactory.createDao("TestDAO", "TST");
        dao = Dao(daoAddress);
        dex = dao.dex();
        _initUser(TOKEN_HOLDER, 1000 ether, 1000 ether, 1000 ether);
        _initUser(NON_TOKEN_HOLDER, 1000 ether, 0, 1000 ether);
        _initUser(NO_ALLOWANCE_TOKEN_HOLDER, 1000 ether, 1000 ether, 0);
    }

    function testDepositLiquidity() external {
        uint256 ethAmount = 1 ether;
        vm.startPrank(TOKEN_HOLDER);

        dex.deposit{value: ethAmount}();

        vm.stopPrank();
        uint256 userLiquidity = dex.getLiquidity(TOKEN_HOLDER);
        assertEq(userLiquidity, ethAmount);
        uint256 dexEthBalance = address(dex).balance;
        uint256 dexTokenBalance = dao.token().balanceOf(address(dex));
        assertEq(dexEthBalance, ethAmount);
        assertEq(dexTokenBalance, ethAmount);
    }

    function testDepositLiquidityNonTokenHolder() external {
        uint256 ethAmount = 1 ether;
        vm.startPrank(NON_TOKEN_HOLDER);
        vm.expectRevert();
        dex.deposit{value: ethAmount}();
        vm.stopPrank();
    }

    function testDepositLiquidityNoAllowance() external {
        uint256 ethAmount = 1 ether;
        vm.startPrank(NO_ALLOWANCE_TOKEN_HOLDER);
        vm.expectRevert();
        dex.deposit{value: ethAmount}();
        vm.stopPrank();
    }

    function testWIthdrawLiquidity() external {
        uint256 ethAmount = 1 ether;
        uint256 initialUserEthBalance = TOKEN_HOLDER.balance;
        vm.startPrank(TOKEN_HOLDER);
        dex.deposit{value: ethAmount}();
        uint256 afterDepositUserEthBalance = TOKEN_HOLDER.balance;

        (uint256 ethWithdrawn, uint256 tokensWithdrawn) = dex.withdraw(ethAmount);

        vm.stopPrank();
        uint256 finalUserEthBalance = TOKEN_HOLDER.balance;
        assertEq(finalUserEthBalance, initialUserEthBalance);
        assertEq(afterDepositUserEthBalance, initialUserEthBalance - ethAmount);
        assertEq(ethWithdrawn, ethAmount);
        assertEq(tokensWithdrawn, ethAmount);
        assertEq(dex.getLiquidity(TOKEN_HOLDER), 0);
    }

    function testWithdrawLiquidityInsufficient() external {
        uint256 ethAmount = 1 ether;
        vm.startPrank(TOKEN_HOLDER);
        dex.deposit{value: ethAmount}();
        vm.expectRevert();
        dex.withdraw(2 ether);
        vm.stopPrank();
    }

    function testTokenToEthSwap() external {
        uint256 ethAmount = 1 ether;
        vm.startPrank(TOKEN_HOLDER);
        dex.deposit{value: ethAmount}();
        uint256 tokensToSwap = 0.5 ether;

        uint256 ethReceived = dex.tokenToEth(tokensToSwap);

        vm.stopPrank();
        assertGt(ethReceived, 0);
        assertLt(ethReceived, ethAmount);
    }

    function testTokenToEthSwapNoAllowance() external {
        uint256 tokensToSwap = 0.5 ether;
        vm.startPrank(NO_ALLOWANCE_TOKEN_HOLDER);
        vm.expectRevert();
        dex.tokenToEth(tokensToSwap);
        vm.stopPrank();
    }

    function testTokenToEthSwapInsufficientTokens() external {
        uint256 tokensToSwap = 0.5 ether;
        vm.startPrank(NON_TOKEN_HOLDER);
        vm.expectRevert();
        dex.tokenToEth(tokensToSwap);
        vm.stopPrank();
    }

    function testEthToTokenSwap() external {
        uint256 ethAmount = 1 ether;
        vm.startPrank(TOKEN_HOLDER);
        dex.deposit{value: ethAmount}();
        uint256 ethToSwap = 0.5 ether;
        vm.stopPrank();

        vm.startPrank(NON_TOKEN_HOLDER);
        uint256 tokensReceived = dex.ethToToken{value: ethToSwap}();

        vm.stopPrank();
        assertGt(tokensReceived, 0);
        assertLt(tokensReceived, ethToSwap);
    }
}
