// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {SubPlanFactory} from "../src/SubPlanFactory.sol";
import {SubPlan} from "../src/SubPlan.sol";


contract SubPlanFactoryTest is Test {
    SubPlanFactory factory;
    address owner;
    uint256 subAmount = 1 ether;
    uint256 subDuration = 30 days;

    function setUp() external {
        factory = new SubPlanFactory();
        owner = makeAddr('owner');
    }

    function testCreateSubPlan() external {
        address subPlanAddress = factory.createSubPlan(subAmount, subDuration);

        assertTrue(subPlanAddress != address(0), "SubPlan address should not be zero");
        SubPlan subPlan = SubPlan(subPlanAddress);
        assertEq(subPlan.subAmount(), subAmount, "SubAmount should be set correctly");
        assertEq(subPlan.subDuration(), subDuration, "SubDuration should be set correctly");
        assertEq(subPlan.owner(), address(this), "Owner should be the caller");
    }

    function testCreateSubPlanFor() external {
        address subPlanAddress = factory.createSubPlanFor(subAmount, subDuration, owner);

        assertTrue(subPlanAddress != address(0), "SubPlan address should not be zero");
        SubPlan subPlan = SubPlan(subPlanAddress);
        assertEq(subPlan.subAmount(), subAmount, "SubAmount should be set correctly");
        assertEq(subPlan.subDuration(), subDuration, "SubDuration should be set correctly");
        assertEq(subPlan.owner(), owner, "Owner should be the specified address");
    }

   
}
