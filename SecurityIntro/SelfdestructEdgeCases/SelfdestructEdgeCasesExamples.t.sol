// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableInvariantBank,
    FixedAccountingBank,
    ForceSender
} from "./SelfdestructEdgeCasesExamples.sol";

contract SelfdestructEdgeCasesExamplesTest is Test {
    address internal alice = makeAddr("alice");

    function setUp() external {
        vm.deal(alice, 1 ether);
    }

    function testForcedEtherBreaksStrictBalanceInvariant() external {
        VulnerableInvariantBank bank = new VulnerableInvariantBank();
        vm.prank(alice);
        bank.deposit{value: 1 ether}();
        ForceSender bomber = new ForceSender{value: 1 wei}();

        bomber.forceSend(payable(address(bank)));

        vm.expectRevert();
        vm.prank(alice);
        bank.withdraw(1 ether);
    }

    function testAccountingBankStillAllowsWithdrawAfterForcedEther() external {
        FixedAccountingBank bank = new FixedAccountingBank();
        vm.prank(alice);
        bank.deposit{value: 1 ether}();
        ForceSender bomber = new ForceSender{value: 1 wei}();

        bomber.forceSend(payable(address(bank)));

        vm.prank(alice);
        bank.withdraw(1 ether);
        assertEq(alice.balance, 1 ether);
    }
}
