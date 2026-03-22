// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    error DexAlreadyInitialized();
    error TokenTransferFailed();

    IERC20 public immutable TOKEN;

    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    constructor(address tokenAddr) {
        TOKEN = IERC20(tokenAddr);
    }

    function init(uint256 tokens) public payable returns (uint256 initialLiquidity) {
        // TODO: check balance?
        if (totalLiquidity > 0) {
            revert DexAlreadyInitialized();
        }

        initialLiquidity = address(this).balance;
        liquidity[msg.sender] = initialLiquidity;
        totalLiquidity = initialLiquidity;

        if (!TOKEN.transferFrom(msg.sender, address(this), tokens)) revert TokenTransferFailed();
        return initialLiquidity;
    }

    function price(uint256 xInput, uint256 xReserves, uint256 yReserves) public pure returns (uint256 yOutput) {
        uint256 xInputWithFee = xInput * 997;
        uint256 numerator = xInputWithFee * yReserves;
        uint256 denominator = (xReserves * 1000) + xInputWithFee;
        return numerator / denominator;
    }

    function getLiquidity(address lp) public view returns (uint256 lpLiquidity) {
        return liquidity[lp];
    }

    function ethToToken() public payable returns (uint256 tokenOutput) {
        // Your code here...
    }

    function tokenToEth(uint256 tokenInput) public returns (uint256 ethOutput) {
        // Your code here...
    }

    function deposit() public payable returns (uint256 tokensDeposited) {
        // Your code here...
    }

    function withdraw(uint256 amount) public returns (uint256 ethAmount, uint256 tokenAmount) {
        // Your code here...
    }
}
