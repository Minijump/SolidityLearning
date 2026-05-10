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
/// gas costs: calldata < memory << storage
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_ArrayInput_ --gas-report
contract ArrayInputExample {
    uint256[] internal contractValues;

    constructor() {
        contractValues.push(1);
    }

    /// gas cost: 1588 (for values length 1)
    function sumMemory(uint256[] memory values) external pure returns (uint256 total) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            total += values[i];
        }
    }

    /// gas cost: 998 (for values length 1)
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

/// @notice Comparison: repeatedly reading the same storage slot vs caching it in memory.
///
/// reading data from storage is more expensive than reading from memory, so caching a frequently read value can save gas.
/// Note that using a variable that is read only once, can still be more efficient in some cases (reasons are advanced; opcode, optimizer, ...)
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_StorageRead_ --gas-report
contract StorageReadExample {
    uint256 public feeBps = 30;
    uint256 public amountA = 2 ether;
    uint256 public amountB = 4 ether;

    // gas cost: 7858
    function quoteWithoutCache() external view returns (uint256 totalFee) {
        uint256 feeA = (amountA * feeBps) / 10_000;
        uint256 feeB = (amountB * feeBps) / 10_000;
        totalFee = feeA + feeB;
    }

    // gas cost: 7749
    function quoteWithCache() external view returns (uint256 totalFee) {
        uint256 cachedFeeBps = feeBps;
        uint256 feeA = (amountA * cachedFeeBps) / 10_000;
        uint256 feeB = (amountB * cachedFeeBps) / 10_000;
        totalFee = feeA + feeB;
    }
}

/// @notice Comparison: storage config values vs constant and immutable values.
///
/// usage of immutable and constant variables is more efficient than 'simple' storage variables
/// gas costs: constant < immutable << storage
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_ConstantImmutable_ --gas-report
contract ConstantImmutableExample {
    uint256 public feeBpsStorage = 30;
    uint256 public denominatorStorage = 10_000;
    uint256 public immutable denominatorImmutable;
    uint256 public constant DENOMINATOR_CONSTANT = 10_000;

    constructor() {
        denominatorImmutable = 10_000;
    }

    // gas cost: 5218
    function quoteWithStorageConfig(uint256 amount) external view returns (uint256) {
        return (amount * feeBpsStorage) / denominatorStorage;
    }

    // gas cost: 3184
    function quoteWithImmutableConfig(uint256 amount) external view returns (uint256) {
        return (amount * feeBpsStorage) / denominatorImmutable;
    }

    // gas cost: 3140
    function quoteWithConstantConfig(uint256 amount) external view returns (uint256) {
        return (amount * feeBpsStorage) / DENOMINATOR_CONSTANT;
    }
}

/// @notice Comparison: dynamic string identifiers vs fixed-size bytes32 identifiers.
///
/// bytes are more efficient for static data, but less for dynamic, are less readable and need more validation work, ...
/// common good practice is to Use bytes32 for fixed-size keys/IDs. (or when it is really needed)
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_IdentifierType_ --gas-report
contract IdentifierTypeExample {
    mapping(string => uint256) public byString;
    mapping(bytes32 => uint256) public byBytes32;

    // gas cost: 44868
    function setByString(string calldata id, uint256 value) external {
        byString[id] = value;
    }

    // gas cost: 44282
    function setByBytes32(bytes32 id, uint256 value) external {
        byBytes32[id] = value;
    }
}

/// @notice Comparison: writing to storage multiple times vs computing first and writing once.
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_StorageWrite_ --gas-report
contract StorageWriteExample {
    uint256 public total;

    function writeMultipleTimes(uint256 amount) external {
        total = total + amount;
        total = total + 1;
    }

    function writeOnce(uint256 amount) external {
        uint256 newTotal = total + amount + 1;
        total = newTotal;
    }
}

/// @notice Comparison: expensive work before a failing check vs fail-fast check ordering.
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_CheckOrder_ --gas-report
contract CheckOrderExample {
    function expensiveThenCheck(uint256 amount, bytes calldata payload) external pure returns (bytes32 digest) {
        digest = keccak256(payload);
        require(amount <= 100, "amount too high");
    }

    function checkThenExpensive(uint256 amount, bytes calldata payload) external pure returns (bytes32 digest) {
        require(amount <= 100, "amount too high");
        digest = keccak256(payload);
    }
}

/// @notice Comparison: public function with memory array vs external function with calldata array.
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_VisibilityInput_ --gas-report
contract VisibilityInputExample {
    function sumPublic(uint256[] memory values) public pure returns (uint256 total) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            total += values[i];
        }
    }

    function sumExternal(uint256[] calldata values) external pure returns (uint256 total) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            total += values[i];
        }
    }
}

/// @notice Comparison: verbose events with extra data vs lean events.
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_Event_ --gas-report
contract EventExample {
    event TransferVerbose(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp,
        bytes32 indexed transferId,
        string note
    );

    event TransferLean(address indexed from, address indexed to, uint256 amount);

    function emitVerbose(address to, uint256 amount, bytes32 transferId, string calldata note) external {
        emit TransferVerbose(msg.sender, to, amount, block.timestamp, transferId, note);
    }

    function emitLean(address to, uint256 amount) external {
        emit TransferLean(msg.sender, to, amount);
    }
}

/// @notice Comparison: heavier ABI encoding in a loop vs lighter packed encoding.
///
/// Run: forge test --match-path test/GasBasics.t.sol --match-test test_AbiEncoding_ --gas-report
contract AbiEncodingExample {
    function hashWithEncode(uint256[] calldata values) external pure returns (bytes32 result) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            result = keccak256(abi.encode(result, values[i]));
        }
    }

    function hashWithEncodePacked(uint256[] calldata values) external pure returns (bytes32 result) {
        uint256 length = values.length;
        for (uint256 i = 0; i < length; ++i) {
            result = keccak256(abi.encodePacked(result, values[i]));
        }
    }
}
