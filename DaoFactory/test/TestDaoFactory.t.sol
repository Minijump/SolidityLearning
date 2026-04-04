// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {DaoFactory} from "../src/DaoFactory.sol";
import {Dao} from "../src/Dao.sol";


contract DaoFactoryTest is Test {
    DaoFactory daoFactory;
    address USER = makeAddr("user");

    function _initUser(address user, uint256 initialEthBalance) internal {
        vm.deal(user, initialEthBalance);
    }

    function setUp() external {
        daoFactory = new DaoFactory();
        _initUser(USER, 100 ether);
    }

    function testCreateDao() external {
        vm.startPrank(USER);
        address daoAddress = daoFactory.createDao("TestDAO", "TST");
        vm.stopPrank();

        assert(daoAddress != address(0));
        assertEq(Dao(daoAddress).name(), "TestDAO", "DAO name should be 'TestDAO'");
        assertEq(Dao(daoAddress).symbol(), "TST", "DAO symbol should be 'TST'");
    }
}
