// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Mimics USDT: transfer()/transferFrom()/approve() move balances correctly
// but return nothing, instead of the bool the ERC20 standard specifies.
// Calling these through the IERC20 interface makes Solidity try to decode
// a bool from empty return data, which reverts - this is exactly the case
// SafeERC20 is built to handle.
contract NonCompliantToken {
    string public name = "Non Compliant Token";
    string public symbol = "NCT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply;
    }

    function transfer(address to, uint256 amount) public {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    function transferFrom(address from, address to, uint256 amount) public {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
    }
}
