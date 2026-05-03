// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableRefundEscrow,
    RefundBlocker
} from "./DenialOfServiceExamples.sol";

contract DenialOfServiceExamplesTest is Test {
    address internal alice = makeAddr("alice");
    VulnerableRefundEscrow internal escrow;
    RefundBlocker internal blocker;

    function setUp() external {
        vm.deal(alice, 1 ether);
        escrow = new VulnerableRefundEscrow();
        blocker = new RefundBlocker();
        vm.deal(address(blocker), 1 ether);
    }

    function testBlockingRecipientBreaksPushRefundLoop() external {
        vm.prank(alice);
        escrow.contribute{value: 1 ether}();

        vm.prank(address(blocker));
        blocker.contributeToVulnerable{value: 1 ether}(escrow);

        vm.expectRevert();
        escrow.refundAll();
        assertEq(address(escrow).balance, 2 ether);
    }
}
