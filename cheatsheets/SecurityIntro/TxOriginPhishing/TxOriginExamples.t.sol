// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableTxOriginWallet,
    TxOriginPhishingAttacker,
    PatchedWallet
} from "./TxOriginExamples.sol";

contract TxOriginExamplesTest is Test {
    address internal owner = makeAddr("owner");
    address payable internal thief = payable(makeAddr("thief"));

    function setUp() external {
        vm.deal(owner, 10 ether);
    }

    function _fundWallet(VulnerableTxOriginWallet wallet) internal {
        vm.prank(owner);
        (bool funded,) = address(wallet).call{value: 5 ether}("");
        require(funded, "fund failed");
    }

    function testPhishingContract() external {
        VulnerableTxOriginWallet wallet = new VulnerableTxOriginWallet(owner);
        _fundWallet(wallet);
        TxOriginPhishingAttacker attacker = new TxOriginPhishingAttacker(payable(address(wallet)), thief);

        // Owner is tricked into sending ETH to the attacker (e.g. "pay 0.1 ETH to mint your NFT").
        // The attacker's receive() exploits tx.origin == owner to drain the wallet as a side-effect.
        // vm.prank(owner, owner): msg.sender = owner, tx.origin = owner (simulates owner as the EOA).
        vm.prank(owner, owner);
        (bool success,) = address(attacker).call{value: 0.1 ether}("");
        require(success, "attack call failed");

        assertEq(address(wallet).balance, 0);
        assertEq(thief.balance, 5 ether);
    }

    function testPatchedWallet() external {
        PatchedWallet wallet = new PatchedWallet(owner);
        _fundWallet(wallet);
        TxOriginPhishingAttacker attacker = new TxOriginPhishingAttacker(payable(address(wallet)), thief);

        vm.prank(owner, owner);
        (bool success,) = address(attacker).call{value: 0.1 ether}("");
        assertFalse(success);

        assertEq(address(wallet).balance, 5 ether);
        assertEq(thief.balance, 0);
    }
}
