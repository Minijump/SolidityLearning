// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableInvariantBank {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    function _canWithdraw(uint256 amount) internal view virtual {
        require(balances[msg.sender] >= amount, "insufficient");
        require(address(this).balance == totalDeposits, "invariant broken");
    }

    function withdraw(uint256 amount) external {
        _canWithdraw(amount);

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
    }
}

contract FixedAccountingBank is VulnerableInvariantBank {
    function _canWithdraw(uint256 amount) internal view override {
        require(balances[msg.sender] >= amount, "insufficient");
    }
}

contract ForceSender {
    constructor() payable {}

    function forceSend(address payable target) external {
        selfdestruct(target);
    }
}
