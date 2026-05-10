// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {
    AbiEncodingExample,
    ArrayInputExample,
    CheckOrderExample,
    ConstantImmutableExample,
    CustomErrorExample,
    EventExample,
    IdentifierTypeExample,
    PackingExample,
    StorageReadExample,
    StorageWriteExample,
    VisibilityInputExample
} from "../src/GasBasics.sol";

contract GasBasicsTest is Test {
    ArrayInputExample internal arrayInputExample;
    AbiEncodingExample internal abiEncodingExample;
    CheckOrderExample internal checkOrderExample;
    ConstantImmutableExample internal constantImmutableExample;
    CustomErrorExample internal customErrorExample;
    EventExample internal eventExample;
    IdentifierTypeExample internal identifierTypeExample;
    PackingExample internal packingExample;
    StorageReadExample internal storageReadExample;
    StorageWriteExample internal storageWriteExample;
    VisibilityInputExample internal visibilityInputExample;

    uint256[] internal values;
    bytes internal payload;

    function setUp() public {
        arrayInputExample = new ArrayInputExample();
        abiEncodingExample = new AbiEncodingExample();
        checkOrderExample = new CheckOrderExample();
        constantImmutableExample = new ConstantImmutableExample();
        customErrorExample = new CustomErrorExample();
        eventExample = new EventExample();
        identifierTypeExample = new IdentifierTypeExample();
        packingExample = new PackingExample();
        storageReadExample = new StorageReadExample();
        storageWriteExample = new StorageWriteExample();
        visibilityInputExample = new VisibilityInputExample();
        values.push(1);
        values.push(2);
        values.push(3);
        values.push(4);
        payload = abi.encodePacked("this payload is intentionally long enough to make keccak meaningful");
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

    //===============================================================

    function test_StorageRead_WithoutCache() public view {
        storageReadExample.quoteWithoutCache();
    }

    function test_StorageRead_WithCache() public view {
        storageReadExample.quoteWithCache();
    }

    //===============================================================

    function test_ConstantImmutable_StorageConfig() public view {
        constantImmutableExample.quoteWithStorageConfig(1 ether);
    }

    function test_ConstantImmutable_ImmutableConfig() public view {
        constantImmutableExample.quoteWithImmutableConfig(1 ether);
    }

    function test_ConstantImmutable_ConstantConfig() public view {
        constantImmutableExample.quoteWithConstantConfig(1 ether);
    }

    //===============================================================

    function test_IdentifierType_String() public {
        identifierTypeExample.setByString("BTC-USD", 1e18);
    }

    function test_IdentifierType_Bytes32() public {
        identifierTypeExample.setByBytes32(bytes32("BTC-USD"), 1e18);
    }

    //===============================================================

    function test_StorageWrite_MultipleWrites() public {
        storageWriteExample.writeMultipleTimes(5);
    }

    function test_StorageWrite_WriteOnce() public {
        storageWriteExample.writeOnce(5);
    }

    //===============================================================

    function test_CheckOrder_ExpensiveThenCheck_Revert() public {
        vm.expectRevert("amount too high");
        checkOrderExample.expensiveThenCheck(1_000, payload);
    }

    function test_CheckOrder_CheckThenExpensive_Revert() public {
        vm.expectRevert("amount too high");
        checkOrderExample.checkThenExpensive(1_000, payload);
    }

    //===============================================================

    function test_VisibilityInput_Public() public view {
        visibilityInputExample.sumPublic(values);
    }

    function test_VisibilityInput_External() public view {
        visibilityInputExample.sumExternal(values);
    }

    //===============================================================

    function test_Event_Verbose() public {
        eventExample.emitVerbose(address(2), 10 ether, bytes32("id-1"), "settlement event with extra metadata");
    }

    function test_Event_Lean() public {
        eventExample.emitLean(address(2), 10 ether);
    }

    //===============================================================

    function test_AbiEncoding_Encode() public view {
        abiEncodingExample.hashWithEncode(values);
    }

    function test_AbiEncoding_EncodePacked() public view {
        abiEncodingExample.hashWithEncodePacked(values);
    }
}
