// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error ValueTooLarge(uint256 provided, uint256 maxAllowed);

/// @notice Comparison: long revert strings vs custom errors.
///
/// In the following example, the custom error is more gas efficient than the long revert string,
/// but slightly more expensive than the short revert string
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_CustomError_ --gas-report
contract CustomErrorExample {
    uint256 public value;

    /// gas cost: 43744
    function setWithRequire(uint256 newValue) external {
        require(newValue <= 100, "Too large");
        value = newValue;
    }

    /// gas cost: 43788
    function setWithRequireWithALongErrorMessage(uint256 newValue) external {
        require(newValue <= 100, "value too large, and this error message is also very laaaarge");
        value = newValue;
    }

    /// gas cost: 43766
    function setWithCustomError(uint256 newValue) external {
        if (newValue > 100) revert ValueTooLarge(newValue, 100);
        value = newValue;
    }
}

/// @notice Comparison: copying an input array into memory vs reading it directly from calldata.
/// 
/// memory copy the data, calldata read the data directly from calldata.
/// using storage instead of input is even more expensive.
/// calldata < memory << storage
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_ArrayInput_ --gas-report
contract ArrayInputExample {
    uint256[] internal contractValues;

    constructor() {
        contractValues.push(1);
    }

    /// gas cost: 1588
    function sumMemory(uint256[] memory values) external pure returns (uint256 total) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            total += values[i];
        }
    }

    /// gas cost: 998
    function sumCalldata(uint256[] calldata values) external pure returns (uint256 total) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            total += values[i];
        }
    }

    /// gas cost: 5018
    function sumStorage() external view returns (uint256 total) {
        uint256 length = contractValues.length;
        for (uint256 i = 0; i < length; ++i) {
            total += contractValues[i];
        }
    }
}

/// @notice Comparison: unpacked storage structs vs tightly packed values that share fewer storage slots.
/// 
/// packed struct only uses fewer storage slots. This makes it less expensive to read and write. 
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_Packing_ --gas-report
contract PackingExample {
    struct UnpackedPosition {
        uint256 amount;
        uint256 lastUpdated;
        bool active;
    }

    struct PackedPosition {
        uint128 amount;
        uint64 lastUpdated;
        bool active;
    }

    UnpackedPosition public unpacked; // gas cost: 6922
    PackedPosition public packed; // gas cost: 3127

    // gas cost: 88745
    function writeUnpacked(uint256 amount, bool active, uint256 lastUpdated) external {
        unpacked = UnpackedPosition(amount, lastUpdated, active);
    }

    // gas cost: 45211
    function writePacked(uint128 amount, bool active, uint64 lastUpdated) external {
        packed = PackedPosition(amount, lastUpdated, active);
    }
}
