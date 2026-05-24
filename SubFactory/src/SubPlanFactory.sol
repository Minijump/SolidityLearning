// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {SubPlan} from "./SubPlan.sol";


contract SubPlanFactory {
    function createSubPlan() external returns (address) {
        SubPlan subPlan = new SubPlan();
        return address(subPlan);
    }
}
