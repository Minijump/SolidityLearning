// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ITokenLike {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract HonestToken is ITokenLike {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (balances[from] < amount || allowances[from][msg.sender] < amount) {
            return false;
        }

        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}

contract AlwaysFalseToken is ITokenLike {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }

    function approve(address, uint256) external pure returns (bool) {
        return true;
    }

    function balanceOf(address) external pure returns (uint256) {
        return 0;
    }
}

contract VulnerableTokenShop {
    ITokenLike public immutable token;
    address public immutable treasury;
    uint256 public constant PRICE = 100;
    mapping(address => bool) public hasItem;

    constructor(address tokenAddress, address shopTreasury) {
        token = ITokenLike(tokenAddress);
        treasury = shopTreasury;
    }

    function purchase() external {
        token.transferFrom(msg.sender, treasury, PRICE);
        hasItem[msg.sender] = true;
    }
}

contract FixedTokenShop {
    ITokenLike public immutable token;
    address public immutable treasury;
    uint256 public constant PRICE = 100;
    mapping(address => bool) public hasItem;

    constructor(address tokenAddress, address shopTreasury) {
        token = ITokenLike(tokenAddress);
        treasury = shopTreasury;
    }

    function purchase() external {
        require(token.transferFrom(msg.sender, treasury, PRICE), "payment failed");
        hasItem[msg.sender] = true;
    }
}
