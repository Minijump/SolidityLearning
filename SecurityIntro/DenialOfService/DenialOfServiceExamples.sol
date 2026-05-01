// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableRefundEscrow {
    mapping(address => uint256) public contributions;
    address[] public contributors;

    function contribute() external payable {
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
    }

    function refundAll() external {
        for (uint256 i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint256 amount = contributions[contributor];
            if (amount == 0) {
                continue;
            }

            (bool success,) = payable(contributor).call{value: amount}("");
            require(success, "refund failed");
            contributions[contributor] = 0;
        }
    }
}

contract FixedPullPaymentEscrow {
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public pendingRefunds;
    address[] public contributors;

    function contribute() external payable {
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
    }

    function prepareRefunds() external {
        for (uint256 i = 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint256 amount = contributions[contributor];
            if (amount == 0) {
                continue;
            }

            pendingRefunds[contributor] += amount;
            contributions[contributor] = 0;
        }
    }

    function withdrawRefund() external {
        uint256 amount = pendingRefunds[msg.sender];
        require(amount > 0, "nothing to withdraw");

        pendingRefunds[msg.sender] = 0;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        require(success, "refund failed");
    }
}

contract RefundBlocker {
    function contributeToVulnerable(VulnerableRefundEscrow target) external payable {
        target.contribute{value: msg.value}();
    }

    function contributeToFixed(FixedPullPaymentEscrow target) external payable {
        target.contribute{value: msg.value}();
    }

    function withdrawFromFixed(FixedPullPaymentEscrow target) external {
        target.withdrawRefund();
    }

    receive() external payable {
        revert("refund blocked");
    }
}
