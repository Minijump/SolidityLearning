// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {SubPlan} from "./SubPlan.sol";


contract SubPlanFactory {
    function createSubPlan(uint256 subAmount, uint256 subDuration) external returns (address) {
        return _createSubPlan(subAmount, subDuration, msg.sender);
    }

    function createSubPlanFor(uint256 subAmount, uint256 subDuration, address owner) external returns (address) {
        return _createSubPlan(subAmount, subDuration, owner);
    }

    function _createSubPlan(uint256 subAmount, uint256 subDuration, address owner) internal returns (address) {
        SubPlan subPlan = new SubPlan(subAmount, subDuration, owner);
        return address(subPlan);
    }
}
