// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyUSDEngine, Engine__InvalidAmount, Engine__UnsafePositionRatio, MyUSD__InsufficientAllowance, MyUSD__InsufficientBalance} from "../src/MyUSDEngine.sol";
import {MyUSD} from "../src/MyUSD.sol";
import {DeployMyUSDEngine} from "../script/DeployMyUSDEngine.s.sol";


contract DEXTest is Test {
    MyUSDEngine myUSDEngine;
    address USER_WITHOUT_COLLATERAL = makeAddr("user_without_collateral");
    address USER_WITH_COLLATERAL = makeAddr("user_with_collateral");
    address USER_WITH_USD = makeAddr("user_with_usd");
    MyUSD myUsd;

    function setUp() external {
        DeployMyUSDEngine deployer = new DeployMyUSDEngine();
        myUSDEngine = deployer.run();
        myUsd = myUSDEngine.i_myUSD();

        _initUser(USER_WITHOUT_COLLATERAL, 0, 0);
        _initUser(USER_WITH_COLLATERAL, 100 ether, 0);
        _initUser(USER_WITH_USD, 0, 100 ether);
    }

    function _initUser(address user, uint256 initialCollateral, uint256 initialUSD) internal {
        vm.deal(user, 10000 ether);
        if (initialCollateral > 0) {
            vm.startPrank(user);
            myUSDEngine.addCollateral{value: initialCollateral}();
            vm.stopPrank();
        }
        if (initialUSD > 0) {
            vm.startPrank(user);
            myUSDEngine.addCollateral{value: initialUSD}();
            myUSDEngine.mintMyUSD(initialUSD);
            myUsd.approve(address(myUSDEngine), initialUSD);
            vm.stopPrank();
        }
    }

    function testDeployment() external view{
        assert(address(myUSDEngine) != address(0));
    }

    function testAddCollateral() external {
        uint256 initialCollateral = myUSDEngine.s_userCollateral(USER_WITHOUT_COLLATERAL);

        vm.startPrank(USER_WITHOUT_COLLATERAL);
        myUSDEngine.addCollateral{value: 1 ether}();
        vm.stopPrank();

        uint256 finalCollateral = myUSDEngine.s_userCollateral(USER_WITHOUT_COLLATERAL);
        assertEq(finalCollateral, initialCollateral + 1 ether);
    }

    function testAddCollateralWithZeroValue() external {
        vm.startPrank(USER_WITHOUT_COLLATERAL);
        vm.expectRevert(abi.encodeWithSelector(Engine__InvalidAmount.selector));
        myUSDEngine.addCollateral{value: 0}();
        vm.stopPrank();
    }

    function testMint() external {
        uint256 initialMyUsdBalance = myUsd.balanceOf(USER_WITH_COLLATERAL);

        vm.startPrank(USER_WITH_COLLATERAL);
        myUSDEngine.mintMyUSD(500);
        vm.stopPrank();

        uint256 finalMyUsdBalance = myUsd.balanceOf(USER_WITH_COLLATERAL);
        assertEq(finalMyUsdBalance, initialMyUsdBalance + 500);
    }

    function testMintWithZeroAmount() external {
        vm.startPrank(USER_WITH_COLLATERAL);
        vm.expectRevert(abi.encodeWithSelector(Engine__InvalidAmount.selector));
        myUSDEngine.mintMyUSD(0);
        vm.stopPrank();
    }

    function testMintWithNoCollateral() external {
        vm.startPrank(USER_WITHOUT_COLLATERAL);
        vm.expectRevert(abi.encodeWithSelector(Engine__UnsafePositionRatio.selector));
        myUSDEngine.mintMyUSD(100);
        vm.stopPrank();
    }

    function testRepayUpTo() external {
        uint256 initialMyUsdBalance = myUsd.balanceOf(USER_WITH_USD);
        uint256 initialDebt = myUSDEngine.getCurrentDebtValue(USER_WITH_USD);
        uint256 repayAmount = 50;

        vm.startPrank(USER_WITH_USD);
        myUSDEngine.repayUpTo(repayAmount);
        vm.stopPrank();

        uint256 finalMyUsdBalance = myUsd.balanceOf(USER_WITH_USD);
        uint256 finalDebt = myUSDEngine.getCurrentDebtValue(USER_WITH_USD);
        assertEq(finalDebt, initialDebt - repayAmount);
        assertEq(finalMyUsdBalance, initialMyUsdBalance - repayAmount);
    }

    function testRepayUpToWithZeroAmount() external {
        vm.startPrank(USER_WITH_USD);
        vm.expectRevert(abi.encodeWithSelector(MyUSD__InsufficientBalance.selector));
        myUSDEngine.repayUpTo(0);
        vm.stopPrank();
    }

    function testRepayUpToWithInsufficientAllowance() external {
        uint256 testedAmount = 200000 ether;
        vm.deal(USER_WITH_USD, testedAmount);
    
        vm.startPrank(USER_WITH_USD);
        myUSDEngine.addCollateral{value: testedAmount}();
        myUSDEngine.mintMyUSD(testedAmount);
        vm.expectRevert(abi.encodeWithSelector(MyUSD__InsufficientAllowance.selector));
        myUSDEngine.repayUpTo(testedAmount);
        vm.stopPrank();
     }
}
