// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "../../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";


contract ReentrancyGuardDemo is ReentrancyGuard {
    bool public hasBeenCalled;

    function patchedFunction() external nonReentrant {
        _function();
    }

    function vulnerableFunction() external {
        _function();
    }

    function _function() internal {
        if (hasBeenCalled) {
            return;
        }
        (bool success, ) = msg.sender.call{value: 1 ether}("");
        require(success, "Transfer failed");
        hasBeenCalled = true;
    }
}
