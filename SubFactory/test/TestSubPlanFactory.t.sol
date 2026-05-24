// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {SubPlanFactory} from "../src/SubPlanFactory.sol";
import {SubPlan} from "../src/SubPlan.sol";


contract SubPlanFactoryTest is Test {
    SubPlanFactory factory;

    function setUp() external {
        factory = new SubPlanFactory();
    }

    function testCreateSubPlan() external {
        address subPlanAddress = factory.createSubPlan();

        assertTrue(subPlanAddress != address(0), "SubPlan address should not be zero");
    }

   
}
