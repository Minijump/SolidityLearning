// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../script/Interactions.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant FUND_AMOUNT = 1e18;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, 5e18);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        // Could use interaction script but not necessary here
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = fundMe.iOwner().balance;

        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();

        vm.prank(fundMe.iOwner());
        fundMe.withdraw();

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = fundMe.iOwner().balance;
        
        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + FUND_AMOUNT, preUserBalance);
        assertEq(afterOwnerBalance, preOwnerBalance + FUND_AMOUNT);
    }
}
