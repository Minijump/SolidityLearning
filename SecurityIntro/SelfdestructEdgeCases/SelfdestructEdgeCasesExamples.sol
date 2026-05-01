// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableInvariantBank {
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

contract FixedAccountingBank {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
    }
}

contract ForceSender {
    constructor() payable {}

    function forceSend(address payable target) external {
        selfdestruct(target);
    }
}
