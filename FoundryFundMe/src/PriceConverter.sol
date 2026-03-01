// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Note: AggregatorV3Interface commented out because I do not want to spend time using faucets, ...
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; 


library PriceConverter {
    function getPrice() internal pure returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        // (, int256 answer, , , ) = priceFeed.latestRoundData();

        // return a mock ETH/USD rate
        int256 answer = 2000 * 100000000; // 2000 * 10^8
        return uint256(answer * 10000000000); // 2000 * 10^18
    }

    function getConversionRate(uint256 ethAmount) internal pure returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
}
