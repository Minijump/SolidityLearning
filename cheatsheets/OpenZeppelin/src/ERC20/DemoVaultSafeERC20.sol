// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SafeERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Demonstrates SafeERC20 utility
// because plain IERC20.transfer/transferFrom/approve assume every token
// correctly returns a bool - many real tokens (e.g. USDT) don't.
contract TokenVault {
    using SafeERC20 for IERC20;

    mapping(address token => mapping(address account => uint256 amount)) public balanceOf;

    function deposit(IERC20 token, uint256 amount) external {
        token.safeTransferFrom(msg.sender, address(this), amount); // we use safeTransferFrom here because we don't know if the token is standard-compliant or not
        balanceOf[address(token)][msg.sender] += amount;
    }

    function withdraw(IERC20 token, uint256 amount) external {
        balanceOf[address(token)][msg.sender] -= amount;
        token.safeTransfer(msg.sender, amount); // we use safeTransfer here because we don't know if the token is standard-compliant or not
    }
}
