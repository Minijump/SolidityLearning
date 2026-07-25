// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {AccessControlExample} from "../../src/Access/DemoAccessControl.sol";

contract AccessControlExampleTest is Test {
    AccessControlExample public accessControl;

    address public admin = address(0x1);
    address public user = address(0x2);
    address public nonUser = address(0x3);

    function setUp() public {
        vm.startPrank(admin);
        accessControl = new AccessControlExample();
        accessControl.grantUserRole(user);
        vm.stopPrank();
    }

    function testSetValueByAdmin() public {
        vm.prank(admin);
        accessControl.setValue(42);

        assertEq(accessControl.getValue(), 42);
    }

    function testSetValueByNonAdmin() public {
        vm.prank(user);
        vm.expectRevert();
        accessControl.setValue(42);
    }

    function testGrantUserRole() public {
        vm.prank(admin);
        accessControl.grantUserRole(nonUser);

        assertTrue(accessControl.hasUserRole(nonUser));
    }

    function testRevokeUserRole() public {
        vm.prank(admin);
        accessControl.revokeUserRole(user);

        assertFalse(accessControl.hasUserRole(user));
    }

    function testGrantUserRoleByNonAdmin() public {
        vm.prank(user);
        vm.expectRevert();
        accessControl.grantUserRole(nonUser);
    }

    function testRevokeUserRoleByNonAdmin() public {
        vm.prank(user);
        vm.expectRevert();
        accessControl.revokeUserRole(user);
    }

    function testFunctionOnlyForUserRole() public {
        vm.prank(user);
        string memory result = accessControl.functionOnlyForUserRole();
        assertEq(result, "Hello User");
    }

    function testFunctionOnlyForUserRoleByNonUser() public {
        vm.prank(nonUser);
        vm.expectRevert();
        accessControl.functionOnlyForUserRole();
    }
}
