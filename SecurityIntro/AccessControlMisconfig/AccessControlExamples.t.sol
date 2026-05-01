// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableInitializableVault,
    AccessControlAttacker,
    FixedConstructorVault
} from "./AccessControlExamples.sol";

contract AccessControlExamplesTest is Test {
    address internal victim = makeAddr("victim");
    address internal attackerEoa = makeAddr("attackerEoa");

    function testAttackerCanCaptureUninitializedOwnership() external {
        VulnerableInitializableVault vault = new VulnerableInitializableVault();
        AccessControlAttacker attacker = new AccessControlAttacker();

        vm.deal(victim, 5 ether);

        vm.prank(victim);
        vault.deposit{value: 5 ether}();

        vm.prank(attackerEoa);
        attacker.exploit(vault, payable(attackerEoa));

        assertEq(address(vault).balance, 0);
        assertEq(attackerEoa.balance, 5 ether);
    }

    function testConstructorOwnershipPreventsCapture() external {
        FixedConstructorVault vault = new FixedConstructorVault(victim);
        AccessControlAttacker attacker = new AccessControlAttacker();

        vm.deal(victim, 5 ether);

        vm.prank(victim);
        vault.deposit{value: 5 ether}();

        vm.expectRevert();
        vm.prank(attackerEoa);
        attacker.exploit(VulnerableInitializableVault(payable(address(vault))), payable(attackerEoa));

        assertEq(address(vault).balance, 5 ether);
    }
}
