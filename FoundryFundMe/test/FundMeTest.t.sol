// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
    }

    function testMinIsFive() public view{
        uint256 min = fundMe.MINIMUM_USD();
        assertEq(min, 5 * 1e18);
    }
}
