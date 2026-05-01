// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableEtherVault,
    ReentrancyAttacker,
    FixedEtherVault,
    FailedReentrancyAttacker
} from "./ReentrancyExamples.sol";

contract ReentrancyExamplesTest is Test {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    function testExploitDrainsVulnerableVault() external {
        VulnerableEtherVault vault = new VulnerableEtherVault();
        ReentrancyAttacker attacker = new ReentrancyAttacker(address(vault));

        vm.deal(alice, 5 ether);
        vm.deal(address(attacker), 1 ether);

        vm.prank(alice);
        vault.deposit{value: 5 ether}();

        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 0);
        assertEq(address(attacker).balance, 6 ether);
    }

    function testFixedVaultStopsReentrancy() external {
        FixedEtherVault vault = new FixedEtherVault();
        FailedReentrancyAttacker attacker = new FailedReentrancyAttacker(address(vault));

        vm.deal(bob, 5 ether);
        vm.deal(address(attacker), 1 ether);

        vm.prank(bob);
        vault.deposit{value: 5 ether}();

        vm.expectRevert();
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 5 ether);
    }
}