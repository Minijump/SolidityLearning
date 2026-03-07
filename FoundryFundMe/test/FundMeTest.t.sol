// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant FUND_AMOUNT = 1e18;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, 5e18);
    }

    function testMinIsFive() public view{
        uint256 min = fundMe.MINIMUM_USD();

        assertEq(min, 5 * 1e18);
    }

    function testOwnerIsMsgSender() public view{
        address owner = fundMe.iOwner();

        assertEq(owner, msg.sender);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();

        fundMe.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();

        uint256 amountFunded = fundMe.addressToAmountFunded(USER);
        assertEq(amountFunded, FUND_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();

        address funder = fundMe.funders(0);
        assertEq(funder, USER);
    }
}
