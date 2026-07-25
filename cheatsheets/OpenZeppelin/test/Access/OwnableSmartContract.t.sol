// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {OwnableExample} from "../../src/Access/OwnableSmartContract.sol";

contract OwnableExampleTest is Test {
    OwnableExample ownableExample;

    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        vm.prank(alice);
        ownableExample = new OwnableExample();
    }

    function testSetValueByOwner() public {
        uint256 newValue = 42;

        vm.prank(alice);
        ownableExample.setValue(newValue);

        assertEq(ownableExample.getValue(), newValue);
    }

    function testSetValueByNonOwner() public {
        uint256 newValue = 42;

        vm.prank(bob);
        vm.expectRevert();
        ownableExample.setValue(newValue);
    }

    function testTransferOwnership() public {
        vm.prank(alice);
        ownableExample.transferOwnership(bob);

        assertEq(ownableExample.owner(), bob);
    }

    function testRenounceOwnership() public {
        vm.prank(alice);
        ownableExample.renounceOwnership();

        assertEq(ownableExample.owner(), address(0));
    }
}
