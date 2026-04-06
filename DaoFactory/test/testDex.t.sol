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

    uint256 ethAmount = 1 ether;

    address TOKEN_HOLDER = makeAddr("tokenHolder");
    address NON_TOKEN_HOLDER = makeAddr("nonTokenHolder");
    address NO_ALLOWANCE_TOKEN_HOLDER = makeAddr("noAllowanceTokenHolder");

    function _depositInitialLiquidity(address user, uint256 initialEthAmount) internal {
        vm.startPrank(user);
        dex.deposit{value: initialEthAmount}();
        vm.stopPrank();
    }

    modifier withInitialLiquidity() {
        _depositInitialLiquidity(TOKEN_HOLDER, ethAmount);
        _;
    }

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

    function testDepositLiquiditySecondTime() external withInitialLiquidity {
        vm.startPrank(TOKEN_HOLDER);
        dex.deposit{value: ethAmount}();
        vm.stopPrank();

        uint256 userLiquidity = dex.getLiquidity(TOKEN_HOLDER);
        assertEq(userLiquidity, 2 * ethAmount);
        uint256 dexEthBalance = address(dex).balance;
        uint256 dexTokenBalance = dao.token().balanceOf(address(dex));
        assertEq(dexEthBalance, 2 * ethAmount);
        assertEq(dexTokenBalance, 2 * ethAmount + 1);
    }

    function testDepositLiquidityNonTokenHolder() external {
        vm.startPrank(NON_TOKEN_HOLDER);
        vm.expectRevert();
        dex.deposit{value: ethAmount}();
        vm.stopPrank();
    }

    function testDepositLiquidityNoAllowance() external {
        vm.startPrank(NO_ALLOWANCE_TOKEN_HOLDER);
        vm.expectRevert();
        dex.deposit{value: ethAmount}();
        vm.stopPrank();
    }

    function testWIthdrawLiquidity() external withInitialLiquidity {
        uint256 beforeWithdrawEthBalance = TOKEN_HOLDER.balance;
        
        vm.startPrank(TOKEN_HOLDER);
        (uint256 ethWithdrawn, uint256 tokensWithdrawn) = dex.withdraw(ethAmount);
        vm.stopPrank();

        uint256 afterWithdrawEthBalance = TOKEN_HOLDER.balance;
        assertEq(afterWithdrawEthBalance, beforeWithdrawEthBalance + ethAmount);
        assertEq(ethWithdrawn, ethAmount);
        assertEq(tokensWithdrawn, ethAmount);
        assertEq(dex.getLiquidity(TOKEN_HOLDER), 0);
    }

    function testWithdrawLiquidityInsufficient() external withInitialLiquidity {
        vm.startPrank(TOKEN_HOLDER);
        vm.expectRevert();
        dex.withdraw(2 ether);
        vm.stopPrank();
    }

    function testTokenToEthSwap() external withInitialLiquidity {
        uint256 tokensToSwap = 0.5 ether;
        vm.startPrank(TOKEN_HOLDER);

        uint256 ethReceived = dex.tokenToEth(tokensToSwap);

        vm.stopPrank();
        assertGt(ethReceived, 0);
        assertLt(ethReceived, ethAmount);
    }

    function testTokenToEthSwapNoAllowance() external withInitialLiquidity {
        uint256 tokensToSwap = 0.5 ether;
        vm.startPrank(NO_ALLOWANCE_TOKEN_HOLDER);
        vm.expectRevert();
        dex.tokenToEth(tokensToSwap);
        vm.stopPrank();
    }

    function testTokenToEthSwapInsufficientTokens() external withInitialLiquidity {
        uint256 tokensToSwap = 0.5 ether;
        vm.startPrank(NON_TOKEN_HOLDER);
        vm.expectRevert();
        dex.tokenToEth(tokensToSwap);
        vm.stopPrank();
    }

    function testEthToTokenSwap() external withInitialLiquidity {
        uint256 ethToSwap = 0.5 ether;

        vm.startPrank(NON_TOKEN_HOLDER);
        uint256 tokensReceived = dex.ethToToken{value: ethToSwap}();
        vm.stopPrank();

        assertGt(tokensReceived, 0);
        assertLt(tokensReceived, ethToSwap);
    }
}
