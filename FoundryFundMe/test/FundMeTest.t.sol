// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
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

    function testOwnerIsMsgSender() public view{
        address owner = fundMe.iOwner();
        console.log("owner: ", owner);
        console.log("msg.sender: ", msg.sender);
        console.log("address(this): ", address(this));
        // We deploy test contract, the test contract deploy the FundMe contract, so the owner of the FundMe contract is the test contract
        assertEq(owner, address(this));
    }
}
