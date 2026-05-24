// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {SubPlanFactory} from "../src/SubPlanFactory.sol";
import {SubPlan} from "../src/SubPlan.sol";


contract SubPlanTest is Test {
    SubPlanFactory factory;
    SubPlan subPlan;
    address owner = makeAddr('owner');
    address subscriber = makeAddr('subscriber');
    uint256 subAmount = 1 ether;
    uint256 subDuration = 30 days;

    function setUp() external {
        factory = new SubPlanFactory();
        vm.prank(owner);
        address payable subPlanAddress = payable(factory.createSubPlan(subAmount, subDuration));
        subPlan = SubPlan(subPlanAddress);
        _initUsers();
    }

    function _initUsers() internal {
        vm.deal(owner, 10 ether);
        vm.deal(subscriber, 10 ether);
    }

    function _assertUserIsSub(address _subscriber) internal view {
        uint256 subscriptionTime = subPlan.subPayments(_subscriber);
        assertEq(subscriptionTime, block.timestamp);
    }

    function testSubscribe() external {
        vm.prank(subscriber);
        subPlan.subscribe{value: subAmount}();
        
        _assertUserIsSub(subscriber);
    }

    function testSubscribeWithIncorrectAmount() external {
        vm.prank(subscriber);
        vm.expectRevert(SubPlan.InvalidSubscriptionAmount.selector);
        subPlan.subscribe{value: subAmount - 0.01 ether}();
    }

    function testReceiveSubscribe() external {
        vm.prank(subscriber);
        (bool success, ) = address(subPlan).call{value: subAmount}("");
        require(success, "Call failed");
        
        _assertUserIsSub(subscriber);
    }

    function testReceiveSubscribeWithIncorrectAmount() external {
        vm.prank(subscriber);

        (bool success, bytes memory data) = address(subPlan).call{value: subAmount - 0.01 ether}("");

        assertFalse(success, "Call should have failed");
        assertEq(data, abi.encodeWithSelector(SubPlan.InvalidSubscriptionAmount.selector), "Revert reason mismatch");
    }

    function testFallbackSubscribe() external {
        vm.prank(subscriber);
        (bool success, ) = address(subPlan).call{value: subAmount}("nonEmptyData");
        require(success, "Call failed");
        
        _assertUserIsSub(subscriber);
    }

    function testFallbackSubscribeWithIncorrectAmount() external {
        vm.prank(subscriber);
        
        (bool success, bytes memory data) = address(subPlan).call{value: subAmount - 0.01 ether}("nonEmptyData");

        assertFalse(success, "Call should have failed");
        assertEq(data, abi.encodeWithSelector(SubPlan.InvalidSubscriptionAmount.selector), "Revert reason mismatch");
    }

    function testWithdraw() external {
        vm.prank(subscriber);
        subPlan.subscribe{value: subAmount}();
        uint256 ownerBalanceBefore = owner.balance;

        vm.prank(owner);
        subPlan.withdraw();

        uint256 ownerBalanceAfter = owner.balance;
        assertEq(ownerBalanceAfter, ownerBalanceBefore + subAmount, "Owner should receive the withdrawn amount");
    }

    function testWithdrawByNonOwner() external {
        vm.prank(subscriber);
        subPlan.subscribe{value: subAmount}();

        vm.prank(subscriber);
        vm.expectRevert(SubPlan.NotOwner.selector);
        subPlan.withdraw();
    }
}
