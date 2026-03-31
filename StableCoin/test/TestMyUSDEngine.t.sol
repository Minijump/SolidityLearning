// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyUSDEngine, Engine__InvalidAmount} from "../src/MyUSDEngine.sol";
import {DeployMyUSDEngine} from "../script/DeployMyUSDEngine.s.sol";


contract DEXTest is Test {
    MyUSDEngine myUSDEngine;
    address USER = makeAddr("user");

    function setUp() external {
        DeployMyUSDEngine deployer = new DeployMyUSDEngine();
        myUSDEngine = deployer.run();
        _initUser(USER);
    }

    function _initUser(address user) internal {
        vm.deal(user, 10 ether);
    }

    function testDeployment() external view{
        assert(address(myUSDEngine) != address(0));
    }

    function testAddCollateral() external {
        uint256 initialCollateral = myUSDEngine.s_userCollateral(USER);

        vm.startPrank(USER);
        myUSDEngine.addCollateral{value: 1 ether}();
        vm.stopPrank();

        uint256 finalCollateral = myUSDEngine.s_userCollateral(USER);
        assertEq(finalCollateral, initialCollateral + 1 ether);
    }

    function testAddCollateralWithZeroValue() external {
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Engine__InvalidAmount.selector));
        myUSDEngine.addCollateral{value: 0}();
        vm.stopPrank();
    }
}
