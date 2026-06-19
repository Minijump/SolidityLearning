// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableInitializableVault,
    AccessControlAttacker,
    PatchedInitializableVault
} from "./AccessControlExamples.sol";

contract AccessControlExamplesTest is Test {
    address internal victim = makeAddr("victim");
    address internal attacker = makeAddr("attacker");
    AccessControlAttacker internal attackerContract;

    function setUp() external {
        vm.deal(victim, 5 ether);
        attackerContract = new AccessControlAttacker();
    }

    function testAttackerCanCaptureUninitializedOwnership() external {
        VulnerableInitializableVault vault = new VulnerableInitializableVault();
        vm.prank(victim);
        vault.deposit{value: 5 ether}();

        vm.prank(attacker);
        attackerContract.exploit(vault, payable(attacker));

        assertEq(address(vault).balance, 0);
        assertEq(attacker.balance, 5 ether);
    }

    function testConstructorOwnershipPreventsCapture() external {
        PatchedInitializableVault vault = new PatchedInitializableVault(victim);
        vm.prank(victim);
        vault.deposit{value: 5 ether}();

        vm.expectRevert();
        vm.prank(attacker);
        attackerContract.exploit(vault, payable(attacker));

        assertEq(address(vault).balance, 5 ether);
        assertEq(vault.OWNER(), victim);
    }
}
