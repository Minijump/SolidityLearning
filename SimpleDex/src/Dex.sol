// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    error DexAlreadyInitialized();
    error TokenTransferFailed();
    error InvalidEthAmount();
    error InvalidTokenAmount();
    error InsufficientTokenBalance(uint256 available, uint256 required);
    error InsufficientTokenAllowance(uint256 available, uint256 required);
    error EthTransferFailed(address to, uint256 amount);

    IERC20 public immutable TOKEN;

    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event EthToTokenSwap(address swapper, uint256 tokenOutput, uint256 ethInput);
    event TokenToEthSwap(address swapper, uint256 tokensInput, uint256 ethOutput);

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
        if (msg.value == 0) revert InvalidEthAmount();
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = TOKEN.balanceOf(address(this));
        tokenOutput = price(msg.value, ethReserve, tokenReserve);

        if (!TOKEN.transfer(msg.sender, tokenOutput)) revert TokenTransferFailed();
        emit EthToTokenSwap(msg.sender, tokenOutput, msg.value);
        return tokenOutput;
    }

    function tokenToEth(uint256 tokenInput) public returns (uint256 ethOutput) {
        if (tokenInput == 0) revert InvalidTokenAmount();
        uint256 bal = TOKEN.balanceOf(msg.sender);
        if (bal < tokenInput) revert InsufficientTokenBalance(bal, tokenInput);
        uint256 allow = TOKEN.allowance(msg.sender, address(this));
        if (allow < tokenInput) revert InsufficientTokenAllowance(allow, tokenInput);
        uint256 tokenReserve = TOKEN.balanceOf(address(this));
        ethOutput = price(tokenInput, tokenReserve, address(this).balance);
        if (!TOKEN.transferFrom(msg.sender, address(this), tokenInput)) revert TokenTransferFailed();
        (bool sent, ) = msg.sender.call{ value: ethOutput }("");
        if (!sent) revert EthTransferFailed(msg.sender, ethOutput);
        emit TokenToEthSwap(msg.sender, tokenInput, ethOutput);
        return ethOutput;
    }

    function deposit() public payable returns (uint256 tokensDeposited) {
        // Your code here...
    }

    function withdraw(uint256 amount) public returns (uint256 ethAmount, uint256 tokenAmount) {
        // Your code here...
    }
}
