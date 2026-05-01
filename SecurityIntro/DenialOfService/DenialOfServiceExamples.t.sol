// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableRefundEscrow,
    FixedPullPaymentEscrow,
    RefundBlocker
} from "./DenialOfServiceExamples.sol";

contract DenialOfServiceExamplesTest is Test {
    address internal alice = makeAddr("alice");

    function testBlockingRecipientBreaksPushRefundLoop() external {
        VulnerableRefundEscrow escrow = new VulnerableRefundEscrow();
        RefundBlocker blocker = new RefundBlocker();

        vm.deal(alice, 2 ether);
        vm.deal(address(blocker), 1 ether);

        vm.prank(alice);
        escrow.contribute{value: 2 ether}();

        vm.prank(address(blocker));
        blocker.contributeToVulnerable{value: 1 ether}(escrow);

        vm.expectRevert();
        escrow.refundAll();

        assertEq(address(escrow).balance, 3 ether);
    }

    function testPullPaymentsLetHonestUsersExitAnyway() external {
        FixedPullPaymentEscrow escrow = new FixedPullPaymentEscrow();
        RefundBlocker blocker = new RefundBlocker();

        vm.deal(alice, 2 ether);
        vm.deal(address(blocker), 1 ether);

        vm.prank(alice);
        escrow.contribute{value: 2 ether}();

        vm.prank(address(blocker));
        blocker.contributeToFixed{value: 1 ether}(escrow);

        escrow.prepareRefunds();

        vm.prank(alice);
        escrow.withdrawRefund();

        assertEq(alice.balance, 2 ether);
        assertEq(address(escrow).balance, 1 ether);

        vm.expectRevert();
        vm.prank(address(blocker));
        blocker.withdrawFromFixed(escrow);

        assertEq(address(escrow).balance, 1 ether);
    }
}
