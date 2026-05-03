// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    LogicV1,
    VulnerableProxy,
    FixedProxy,
    ProxyAttacker
} from "./DelegatecallStorageCollisionExamples.sol";

contract DelegatecallStorageCollisionExamplesTest is Test {
    address internal attacker = makeAddr("attacker");

    LogicV1 internal logic;

    function setUp() external {
        logic = new LogicV1();
    }

    function testStorageCollisionLetsAttackerHijackImplementation() external {
        VulnerableProxy proxy = new VulnerableProxy(address(logic));
        vm.deal(address(proxy), 5 ether);
        vm.prank(attacker);
        ProxyAttacker attackerContract = new ProxyAttacker();

        vm.prank(attacker);
        attackerContract.attack(address(proxy));

        assertEq(address(proxy).balance, 0);
        assertEq(attacker.balance, 5 ether);
    }

    function testUnstructuredStoragePreventsImplementationHijack() external {
        FixedProxy proxy = new FixedProxy(address(logic));
        vm.deal(address(proxy), 5 ether);
        vm.prank(attacker);
        ProxyAttacker attackerContract = new ProxyAttacker();

        vm.prank(attacker);
        vm.expectRevert();
        attackerContract.attack(address(proxy));

        assertEq(address(proxy).balance, 5 ether);
        assertEq(attacker.balance, 0);
    }
}
