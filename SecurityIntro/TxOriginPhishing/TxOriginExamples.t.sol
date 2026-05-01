// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableTxOriginWallet,
    TxOriginPhishingAttacker,
    FixedMsgSenderWallet,
    FailedTxOriginPhishingAttacker
} from "./TxOriginExamples.sol";

contract TxOriginExamplesTest is Test {
    address internal owner = makeAddr("owner");
    address payable internal thief = payable(makeAddr("thief"));

    function testPhishingContractBypassesTxOriginAuthorization() external {
        VulnerableTxOriginWallet wallet = new VulnerableTxOriginWallet(owner);
        TxOriginPhishingAttacker attacker = new TxOriginPhishingAttacker(address(wallet), thief);

        vm.deal(owner, 5 ether);

        vm.prank(owner);
        (bool funded,) = address(wallet).call{value: 5 ether}("");
        require(funded, "fund failed");

        vm.prank(owner);
        attacker.trickOwner();

        assertEq(address(wallet).balance, 0);
        assertEq(thief.balance, 5 ether);
    }

    function testMsgSenderAuthorizationStopsPhishingContract() external {
        FixedMsgSenderWallet wallet = new FixedMsgSenderWallet(owner);
        FailedTxOriginPhishingAttacker attacker = new FailedTxOriginPhishingAttacker(address(wallet), thief);

        vm.deal(owner, 5 ether);

        vm.prank(owner);
        (bool funded,) = address(wallet).call{value: 5 ether}("");
        require(funded, "fund failed");

        vm.expectRevert();
        vm.prank(owner);
        attacker.trickOwner();

        assertEq(address(wallet).balance, 5 ether);
        assertEq(thief.balance, 0);
    }
}
