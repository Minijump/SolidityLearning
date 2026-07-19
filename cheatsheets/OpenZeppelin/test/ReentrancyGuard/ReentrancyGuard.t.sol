// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {ReentrancyGuardDemo} from "../../src/ReentrancyGuard/ReentrancyGuardDemo.sol";

contract ReentrantAttackerPatchedFunction {
    ReentrancyGuardDemo public demo;

    constructor(ReentrancyGuardDemo _demo) {
        demo = _demo;
    }

    function attack() external {
        demo.patchedFunction();
    }

    receive() external payable {
        if (address(demo).balance >= 1 ether) {
            demo.patchedFunction();
        }
    }
}

contract ReentrantAttackerVulnerableFunction {
    ReentrancyGuardDemo public demo;

    constructor(ReentrancyGuardDemo _demo) {
        demo = _demo;
    }

    function attack() external {
        demo.vulnerableFunction();
    }

    receive() external payable {
        if (address(demo).balance >= 1 ether) {
            demo.vulnerableFunction();
        }
    }
}

contract ReentrancyGuardDemoTest is Test {
    ReentrancyGuardDemo demo;

    function setUp() public {
        demo = new ReentrancyGuardDemo();
        vm.deal(address(demo), 10 ether);
    }

    function testAttackPatchedFunction() public {
        ReentrantAttackerPatchedFunction attacker = new ReentrantAttackerPatchedFunction(demo);

        vm.expectRevert();
        attacker.attack();

        assertEq(address(demo).balance, 10 ether);
        assertEq(address(attacker).balance, 0 ether);
    }

    function testAttackVulnerableFunction() public {
        ReentrantAttackerVulnerableFunction attacker = new ReentrantAttackerVulnerableFunction(demo);

        attacker.attack();

        assertTrue(demo.hasBeenCalled());
        assertEq(address(demo).balance, 0 ether);
        assertEq(address(attacker).balance, 10 ether);
    }
}