// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {LogicV1, MaliciousLogic, VulnerableProxy, FixedProxy} from "./DelegatecallStorageCollisionExamples.sol";

contract DelegatecallStorageCollisionExamplesTest is Test {
    address internal attacker = makeAddr("attacker");

    function testStorageCollisionLetsAttackerHijackImplementation() external {
        LogicV1 logic = new LogicV1();
        MaliciousLogic malicious = new MaliciousLogic();
        VulnerableProxy proxy = new VulnerableProxy(address(logic));

        vm.deal(address(proxy), 5 ether);

        vm.prank(attacker);
        (bool ok1,) = address(proxy).call(abi.encodeWithSignature("setOwner(address)", address(malicious)));
        require(ok1, "setOwner call failed");

        vm.prank(attacker);
        (bool ok2,) = address(proxy).call(abi.encodeWithSignature("rug(address)", attacker));
        require(ok2, "rug call failed");

        assertEq(address(proxy).balance, 0);
        assertEq(attacker.balance, 5 ether);
    }

    function testUnstructuredStoragePreventsImplementationHijack() external {
        LogicV1 logic = new LogicV1();
        MaliciousLogic malicious = new MaliciousLogic();
        FixedProxy proxy = new FixedProxy(address(logic));

        vm.deal(address(proxy), 5 ether);

        vm.prank(attacker);
        (bool ok1,) = address(proxy).call(abi.encodeWithSignature("setOwner(address)", address(malicious)));
        require(ok1, "logic call should still succeed");

        vm.prank(attacker);
        (bool ok2,) = address(proxy).call(abi.encodeWithSignature("rug(address)", attacker));
        assertFalse(ok2);

        assertEq(address(proxy).balance, 5 ether);
        assertEq(attacker.balance, 0);
    }
}
