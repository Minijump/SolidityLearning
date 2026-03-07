// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
    }

    function testMinIsFive() public view{
        uint256 min = fundMe.MINIMUM_USD();
        assertEq(min, 5 * 1e18);
    }

    function testOwnerIsMsgSender() public view{
        address owner = fundMe.iOwner();
        assertEq(owner, msg.sender);
    }
}
