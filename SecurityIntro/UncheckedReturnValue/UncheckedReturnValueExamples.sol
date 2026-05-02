// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockedToken {
    mapping(address => uint256) public balances;

    constructor(address initialHolder) {
        balances[initialHolder] = 100;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (balances[from] < amount) {
            return false;
        }

        balances[from] -= amount;
        balances[to] += amount;
        return true;
    }
}

contract VulnerableTokenShop {
    MockedToken public immutable TOKEN;
    address public immutable TREASURY;
    uint256 public constant PRICE = 1;
    mapping(address => bool) public hasItem;

    constructor(address shopTreasury) {
        TREASURY = shopTreasury;
        TOKEN = new MockedToken(TREASURY);
    }

    function purchase() external virtual {
        TOKEN.transferFrom(msg.sender, TREASURY, PRICE);
        hasItem[msg.sender] = true;
        // Note that the balances are still right as the transferFrom is correct, 
        // only the return value is ignored, so the actions executed after should not have been executed.
    }
}

contract PatchedTokenShop is VulnerableTokenShop {
    constructor(address shopTreasury) VulnerableTokenShop(shopTreasury) {}

    function purchase() external override {
        require(TOKEN.transferFrom(msg.sender, TREASURY, PRICE), "payment failed");
        hasItem[msg.sender] = true;
    }
}

contract TokenShopAttacker {
    VulnerableTokenShop public immutable TARGET;

    constructor(address targetAddress) {
        TARGET = VulnerableTokenShop(targetAddress);
    }

    function attack() external {
        TARGET.purchase();
    }
}
