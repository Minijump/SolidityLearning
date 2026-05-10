// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {
    ArrayInputExample,
    CustomErrorExample,
    LoopExample,
    PackingExample
} from "../src/GasBasics.sol";

contract GasBasicsTest is Test {
    ArrayInputExample internal arrayInputExample;
    CustomErrorExample internal customErrorExample;
    LoopExample internal loopExample;
    PackingExample internal packingExample;

    uint256[] internal values;

    function setUp() public {
        arrayInputExample = new ArrayInputExample();
        customErrorExample = new CustomErrorExample();
        loopExample = new LoopExample();
        packingExample = new PackingExample();

        values.push(1);
        values.push(2);
        values.push(3);
        values.push(5);
        values.push(8);
        values.push(13);
        values.push(21);
        values.push(34);
    }

    function test_CustomError_RequireString() public {
        customErrorExample.setWithRequire(42);
        assertEq(customErrorExample.value(), 42);
    }

    function test_CustomError_LargeRequireString() public {
        customErrorExample.setWithRequireWithALongErrorMessage(42);
        assertEq(customErrorExample.value(), 42);
    }

    function test_CustomError_CustomError() public {
        customErrorExample.setWithCustomError(42);
        assertEq(customErrorExample.value(), 42);
    }

    function test_ArrayInput_Memory() public view {
        uint256 total = arrayInputExample.sumMemory(values);
        assertEq(total, 87);
    }

    function test_ArrayInput_Calldata() public view {
        uint256 total = arrayInputExample.sumCalldata(values);
        assertEq(total, 87);
    }

    function test_Loop_CheckedIncrement() public view {
        uint256 total = loopExample.sumChecked(20);
        assertEq(total, 190);
    }

    function test_Loop_UncheckedIncrement() public view {
        uint256 total = loopExample.sumUnchecked(20);
        assertEq(total, 190);
    }

    function test_Packing_UnpackedStruct() public {
        packingExample.writeUnpacked(100, true, 1 days);
        (uint256 amount, bool active, uint256 lastUpdated) = packingExample.unpacked();
        assertEq(amount, 100);
        assertTrue(active);
        assertEq(lastUpdated, 1 days);
    }

    function test_Packing_PackedStruct() public {
        packingExample.writePacked(100, true, uint64(1 days));
        (uint128 amount, uint64 lastUpdated, bool active) = packingExample.packed();
        assertEq(amount, 100);
        assertEq(lastUpdated, 1 days);
        assertTrue(active);
    }
}
