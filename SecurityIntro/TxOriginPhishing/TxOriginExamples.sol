// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableTxOriginWallet {
    address public immutable owner;

    constructor(address walletOwner) payable {
        owner = walletOwner;
    }

    receive() external payable {}

    function transferAll(address payable recipient) external {
        require(tx.origin == owner, "not owner origin");

        (bool success,) = recipient.call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}

contract TxOriginPhishingAttacker {
    VulnerableTxOriginWallet public immutable target;
    address payable public immutable thief;

    constructor(address targetAddress, address payable thiefAddress) {
        target = VulnerableTxOriginWallet(targetAddress);
        thief = thiefAddress;
    }

    function trickOwner() external {
        target.transferAll(thief);
    }
}

contract FixedMsgSenderWallet {
    address public immutable owner;

    constructor(address walletOwner) payable {
        owner = walletOwner;
    }

    receive() external payable {}

    function transferAll(address payable recipient) external {
        require(msg.sender == owner, "not owner sender");

        (bool success,) = recipient.call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}

contract FailedTxOriginPhishingAttacker {
    FixedMsgSenderWallet public immutable target;
    address payable public immutable thief;

    constructor(address targetAddress, address payable thiefAddress) {
        target = FixedMsgSenderWallet(targetAddress);
        thief = thiefAddress;
    }

    function trickOwner() external {
        target.transferAll(thief);
    }
}
