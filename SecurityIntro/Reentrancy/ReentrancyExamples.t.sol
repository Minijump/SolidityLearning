// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableEtherVault,
    ReentrancyAttacker,
    PatchedEtherVaultModifier,
    PatchedEtherVaultCEIPattern
} from "./ReentrancyExamples.sol";

contract ReentrancyExamplesTest is Test {
    address internal alice = makeAddr("alice");
    VulnerableEtherVault internal vulnerableVault;
    PatchedEtherVaultModifier internal patchedVaultModifier;
    PatchedEtherVaultCEIPattern internal patchedVaultCEIPattern;

    function setUp() external {
        vulnerableVault = new VulnerableEtherVault();
        patchedVaultModifier = new PatchedEtherVaultModifier();
        patchedVaultCEIPattern = new PatchedEtherVaultCEIPattern();

        vm.deal(alice, 50 ether);
        vm.prank(alice);
        vulnerableVault.deposit{value: 5 ether}();
        vm.prank(alice);
        patchedVaultModifier.deposit{value: 5 ether}();
        vm.prank(alice);
        patchedVaultCEIPattern.deposit{value: 5 ether}();
    }

    function testExploit() external {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(vulnerableVault));
        vm.deal(address(attacker), 1 ether);

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(vulnerableVault).balance, 0);
        assertEq(address(attacker).balance, 6 ether);
    }

    function testPatchedModifier() external {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(patchedVaultModifier));
        vm.deal(address(attacker), 1 ether);

        vm.expectRevert();
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(patchedVaultModifier).balance, 5 ether);
        assertEq(address(attacker).balance, 1 ether);
    }

    function testPatchedCEIPattern() external {
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(patchedVaultCEIPattern));
        vm.deal(address(attacker), 1 ether);

        vm.expectRevert();
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(patchedVaultCEIPattern).balance, 5 ether);
        assertEq(address(attacker).balance, 1 ether);
    }
}