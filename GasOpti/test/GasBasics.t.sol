// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {
    ArrayInputExample,
    CustomErrorExample,
    PackingExample
} from "../src/GasBasics.sol";

contract GasBasicsTest is Test {
    ArrayInputExample internal arrayInputExample;
    CustomErrorExample internal customErrorExample;
    PackingExample internal packingExample;

    uint256[] internal values;

    function setUp() public {
        arrayInputExample = new ArrayInputExample();
        customErrorExample = new CustomErrorExample();
        packingExample = new PackingExample();
        values.push(1);
    }

    //===============================================================

    function test_CustomError_RequireString() public {
        customErrorExample.setWithRequire(42);
    }

    function test_CustomError_LargeRequireString() public {
        customErrorExample.setWithRequireWithALongErrorMessage(42);
    }

    function test_CustomError_CustomError() public {
        customErrorExample.setWithCustomError(42);
    }

    //===============================================================

    function test_ArrayInput_Memory() public view {
        arrayInputExample.sumMemory(values);
    }

    function test_ArrayInput_Calldata() public view {
        arrayInputExample.sumCalldata(values);
    }

    function test_ArrayInput_Storage() public view {
        arrayInputExample.sumStorage();
    }

    //===============================================================

    function test_Packing_UnpackedStruct() public {
        packingExample.writeUnpacked(100, true, 1 days);
        packingExample.unpacked();
    }

    function test_Packing_PackedStruct() public {
        packingExample.writePacked(100, true, uint64(1 days));
        packingExample.packed();
    }
}
