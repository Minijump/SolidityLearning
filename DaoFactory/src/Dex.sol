// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    error TokenTransferFailed();
    error InsufficientTokenBalance(uint256 available, uint256 required);
    error InsufficientTokenAllowance(uint256 available, uint256 required);
    error EthTransferFailed(address to, uint256 amount);
    error InsufficientLiquidity(uint256 available, uint256 required); 

    IERC20 public immutable TOKEN;

    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event EthToTokenSwap(address swapper, uint256 tokenOutput, uint256 ethInput);
    event TokenToEthSwap(address swapper, uint256 tokensInput, uint256 ethOutput);
    event LiquidityProvided(address liquidityProvider, uint256 liquidityMinted, uint256 ethInput, uint256 tokensInput);
    event LiquidityRemoved(address liquidityRemover, uint256 liquidityWithdrawn, uint256 tokensOutput, uint256 ethOutput);

    constructor(address tokenAddr) {
        TOKEN = IERC20(tokenAddr);
    }

    function _price(uint256 xInput, uint256 xReserves, uint256 yReserves) private pure returns (uint256 yOutput) {
        uint256 xInputWithFee = xInput * 997;
        uint256 numerator = xInputWithFee * yReserves;
        uint256 denominator = (xReserves * 1000) + xInputWithFee;
        return numerator / denominator;
    }

    function getLiquidity(address lp) public view returns (uint256 lpLiquidity) {
        return liquidity[lp];
    }

    function _validateTokenTransfer(uint256 amount) private view {
        uint256 bal = TOKEN.balanceOf(msg.sender);
        if (bal < amount) revert InsufficientTokenBalance(bal, amount);
        uint256 allow = TOKEN.allowance(msg.sender, address(this));
        if (allow < amount) revert InsufficientTokenAllowance(allow, amount);
    }

    function ethToToken() public payable returns (uint256 tokenOutput) {
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = TOKEN.balanceOf(address(this));

        tokenOutput = _price(msg.value, ethReserve, tokenReserve);
        if (!TOKEN.transfer(msg.sender, tokenOutput)) revert TokenTransferFailed();

        emit EthToTokenSwap(msg.sender, tokenOutput, msg.value);
        return tokenOutput;
    }

    function tokenToEth(uint256 tokenInput) public returns (uint256 ethOutput) {
        _validateTokenTransfer(tokenInput);
        uint256 tokenReserve = TOKEN.balanceOf(address(this));

        ethOutput = _price(tokenInput, tokenReserve, address(this).balance);
        if (!TOKEN.transferFrom(msg.sender, address(this), tokenInput)) revert TokenTransferFailed();
        (bool sent, ) = msg.sender.call{ value: ethOutput }("");
        if (!sent) revert EthTransferFailed(msg.sender, ethOutput);

        emit TokenToEthSwap(msg.sender, tokenInput, ethOutput);
        return ethOutput;
    }

    function deposit() public payable returns (uint256 tokensDeposited) {
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenReserve = TOKEN.balanceOf(address(this));
        uint256 tokenDeposit;
        uint256 liquidityMinted;
        if (totalLiquidity == 0) {
            tokenDeposit = msg.value; // 1:1 ratio for initial deposit
            liquidityMinted = address(this).balance;
        } else {
            tokenDeposit = (msg.value * tokenReserve / ethReserve) + 1;
            liquidityMinted = msg.value * totalLiquidity / ethReserve;
        }
        _validateTokenTransfer(tokenDeposit);

        liquidity[msg.sender] += liquidityMinted;
        totalLiquidity += liquidityMinted;
        if (!TOKEN.transferFrom(msg.sender, address(this), tokenDeposit)) revert TokenTransferFailed();

        emit LiquidityProvided(msg.sender, liquidityMinted, msg.value, tokenDeposit);
        return tokenDeposit;
    }

    function withdraw(uint256 amount) public returns (uint256 ethAmount, uint256 tokenAmount) {
        uint256 availableLp = liquidity[msg.sender];
        if (availableLp < amount) revert InsufficientLiquidity(availableLp, amount);
        uint256 ethReserve = address(this).balance;
        uint256 tokenReserve = TOKEN.balanceOf(address(this));
        uint256 ethWithdrawn = amount * ethReserve / totalLiquidity;
        uint256 tokensWithdrawn = amount * tokenReserve / totalLiquidity;

        liquidity[msg.sender] -= amount;
        totalLiquidity -= amount;
        (bool sent, ) = payable(msg.sender).call{ value: ethWithdrawn }("");
        if (!sent) revert EthTransferFailed(msg.sender, ethWithdrawn);
        if (!TOKEN.transfer(msg.sender, tokensWithdrawn)) revert TokenTransferFailed();

        emit LiquidityRemoved(msg.sender, amount, tokensWithdrawn, ethWithdrawn);
        return (ethWithdrawn, tokensWithdrawn);
    }
}
