// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error ValueTooLarge(uint256 provided, uint256 maxAllowed);

/// @notice Comparison: long revert strings vs custom errors.
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_CustomError_ --gas-report
contract CustomErrorExample {
    uint256 public value;

    function setWithRequire(uint256 newValue) external {
        require(newValue <= 100, "value too large");
        value = newValue;
    }

    function setWithCustomError(uint256 newValue) external {
        if (newValue > 100) revert ValueTooLarge(newValue, 100);
        value = newValue;
    }
}

/// @notice Comparison: copying an input array into memory vs reading it directly from calldata.
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_ArrayInput_ --gas-report
contract ArrayInputExample {
    function sumMemory(uint256[] memory values) external pure returns (uint256 total) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            total += values[i];
        }
    }

    function sumCalldata(uint256[] calldata values) external pure returns (uint256 total) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            total += values[i];
        }
    }
}

/// @notice Comparison: standard checked loop increments vs unchecked increments when overflow cannot happen.
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_Loop_ --gas-report
contract LoopExample {
    function sumChecked(uint256 limit) external pure returns (uint256 total) {
        for (uint256 i = 0; i < limit; ++i) {
            total += i;
        }
    }

    function sumUnchecked(uint256 limit) external pure returns (uint256 total) {
        for (uint256 i = 0; i < limit;) {
            total += i;
            unchecked {
                ++i;
            }
        }
    }
}

/// @notice Comparison: unpacked storage structs vs tightly packed values that share fewer storage slots.
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_Packing_ --gas-report
contract PackingExample {
    struct UnpackedPosition {
        uint256 amount;
        bool active;
        uint256 lastUpdated;
    }

    struct PackedPosition {
        uint128 amount;
        uint64 lastUpdated;
        bool active;
    }

    UnpackedPosition public unpacked;
    PackedPosition public packed;

    function writeUnpacked(uint256 amount, bool active, uint256 lastUpdated) external {
        unpacked = UnpackedPosition(amount, active, lastUpdated);
    }

    function writePacked(uint128 amount, bool active, uint64 lastUpdated) external {
        packed = PackedPosition(amount, lastUpdated, active);
    }
}
