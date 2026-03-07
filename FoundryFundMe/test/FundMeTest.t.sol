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

    modifier funded {
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();
        _;
    }

    function testAddsFunderToArrayOfFunders() public funded{
        address funder = fundMe.funders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.iOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.iOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.iOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public {
        uint160 numberOfFunders = 10;
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            vm.deal(funder, 5e18);
            vm.prank(funder);
            fundMe.fund{value: FUND_AMOUNT}();
        }
        uint256 startingOwnerBalance = fundMe.iOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.iOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.iOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }
}
