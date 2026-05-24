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

    function testSubscribeToClosedPlan() external {
        vm.prank(owner);
        subPlan.close();

        vm.prank(subscriber);
        vm.expectRevert(SubPlan.SubscriptionPlanClosed.selector);
        subPlan.subscribe{value: subAmount}();
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

    function testIsSubscribed() external {
        vm.prank(subscriber);
        subPlan.subscribe{value: subAmount}();

        bool isSubscribed = subPlan.isSubscribed(subscriber);

        assertTrue(isSubscribed, "Subscriber should be subscribed");
    }

    function testIsSubscribedAfterDuration() external {
        vm.prank(subscriber);
        subPlan.subscribe{value: subAmount}();

        vm.warp(block.timestamp + subDuration + 1);
        bool isSubscribed = subPlan.isSubscribed(subscriber);

        assertFalse(isSubscribed, "Subscriber should not be subscribed after duration");
    }

    function testIsSubscribedWithoutSubscription() external view{
        bool isSubscribed = subPlan.isSubscribed(subscriber);

        assertFalse(isSubscribed, "Subscriber should not be subscribed without subscription");
    }

    function testEditSubAmount() external {
        uint256 newSubAmount = 2 ether;

        vm.prank(owner);
        subPlan.editSubAmount(newSubAmount);

        uint256 currentSubAmount = subPlan.subAmount();
        assertEq(currentSubAmount, newSubAmount, "Subscription amount should be updated");
    }

    function testEditSubAmountByNonOwner() external {
        uint256 newSubAmount = 2 ether;

        vm.prank(subscriber);
        vm.expectRevert(SubPlan.NotOwner.selector);
        subPlan.editSubAmount(newSubAmount);
    }

    function testEditSubDuration() external {
        uint256 newSubDuration = 60 days;

        vm.prank(owner);
        subPlan.editSubDuration(newSubDuration);

        uint256 currentSubDuration = subPlan.subDuration();
        assertEq(currentSubDuration, newSubDuration, "Subscription duration should be updated");
    }

    function testEditSubDurationByNonOwner() external {
        uint256 newSubDuration = 60 days;

        vm.prank(subscriber);
        vm.expectRevert(SubPlan.NotOwner.selector);
        subPlan.editSubDuration(newSubDuration);
    }

    function testEditOwner() external {
        address newOwner = makeAddr('newOwner');

        vm.prank(owner);
        subPlan.editOwner(newOwner);

        address currentOwner = subPlan.owner();
        assertEq(currentOwner, newOwner, "Owner should be updated");
    }

    function testEditOwnerByNonOwner() external {
        address newOwner = makeAddr('newOwner');

        vm.prank(subscriber);
        vm.expectRevert(SubPlan.NotOwner.selector);
        subPlan.editOwner(newOwner);
    }

    function testClose() external {
        vm.prank(owner);
        subPlan.close();

        bool isOpen = subPlan.isOpen();
        assertFalse(isOpen, "Plan should be closed");
    }

    function testCloseByNonOwner() external {
        vm.prank(subscriber);
        vm.expectRevert(SubPlan.NotOwner.selector);
        subPlan.close();
    }

    function testOpenClosedPlan() external {
        vm.prank(owner);
        subPlan.close();

        vm.prank(owner);
        subPlan.open();

        bool isOpen = subPlan.isOpen();
        assertTrue(isOpen, "Plan should be open");
    }

    function testOpenByNonOwner() external {
        vm.prank(owner);
        subPlan.close();

        vm.prank(subscriber);
        vm.expectRevert(SubPlan.NotOwner.selector);
        subPlan.open();
    }
}
