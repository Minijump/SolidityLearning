// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {DaoFactory} from "../src/DaoFactory.sol";
import {Dao} from "../src/Dao.sol";
import {DaoIP} from "../src/DaoIP.sol";
import {Dex} from "../src/Dex.sol";


contract DaoTest is Test {
    Dao dao;

    address TOKEN_HOLDER = makeAddr("tokenHolder");
    address NON_TOKEN_HOLDER = makeAddr("nonTokenHolder");

    function _initUser(address user, uint256 initialEthBalance, uint256 initialDaoTokenBalance) internal {
        vm.deal(user, initialEthBalance);
        if (initialDaoTokenBalance > 0) {
            vm.startPrank(address(this));
            dao.token().transfer(user, initialDaoTokenBalance);
            vm.stopPrank();
            vm.startPrank(user);
            dao.token().approve(address(dao.dex()), initialDaoTokenBalance);
            vm.stopPrank();
        }
    }

    function setUp() external {
        DaoFactory daoFactory = new DaoFactory();
        address daoAddress = daoFactory.createDao("TestDAO", "TST");
        dao = Dao(daoAddress);
        _initUser(TOKEN_HOLDER, 1000 ether, 1000 ether);
    }

    function testDepositLiquidity() external {
        uint256 ethAmount = 1 ether;
        vm.startPrank(TOKEN_HOLDER);

        dao.dex().deposit{value: ethAmount}();

        vm.stopPrank();
        uint256 userLiquidity = dao.dex().getLiquidity(TOKEN_HOLDER);
        assertEq(userLiquidity, ethAmount);
        uint256 dexEthBalance = address(dao.dex()).balance;
        uint256 dexTokenBalance = dao.token().balanceOf(address(dao.dex()));
        assertEq(dexEthBalance, ethAmount);
        assertEq(dexTokenBalance, ethAmount);
    }
}
