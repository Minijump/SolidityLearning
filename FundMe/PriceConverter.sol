// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

library PriceConverter {
    function getPrice() internal pure returns (uint256){
        // should use an oracle here
        uint256 price = 300000000000;
        return (price * 1e10);// 8 decimals on price, 18 for eth><wei
    }

    function getConversionRate(uint256 ethAmount) internal pure returns (uint256){
        uint256 price = getPrice();
        uint256 ethAmountInUsd = (price * ethAmount) / 1e18; // divided because both side of '*' have 18 decimals
        return ethAmountInUsd;
    }
}