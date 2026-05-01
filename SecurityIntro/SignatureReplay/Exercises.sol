// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Use one valid signature twice to claim funds twice.
A2: Extend replay to multiple recipients if digest format permits it.
*/
contract ExerciseA_VulnerableClaims {
    address public immutable SIGNER;

    constructor(address trustedSigner) payable {
        SIGNER = trustedSigner;
    }

    function claim(address payable recipient, uint256 amount, bytes32 salt, bytes calldata signature) external {
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(this)));
        require(_recover(digest, signature) == SIGNER, "bad signature");

        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "transfer failed");
    }

    function _recover(bytes32 digest, bytes calldata sig) internal pure returns (address) {
        require(sig.length == 65, "bad sig length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := byte(0, calldataload(add(sig.offset, 64)))
        }
        return ecrecover(digest, v, r, s);
    }
}

/*
Exercise Type B (write fix):
Working replay attacker is provided. Patch only the vulnerable contract.
*/
contract ExerciseB_VulnerableClaims {
    address public immutable SIGNER;

    constructor(address trustedSigner) payable {
        SIGNER = trustedSigner;
    }

    function claim(address payable recipient, uint256 amount, bytes32 salt, bytes calldata signature) external {
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(this)));
        require(_recover(digest, signature) == SIGNER, "bad signature");

        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "transfer failed");
    }

    function _recover(bytes32 digest, bytes calldata sig) internal pure returns (address) {
        require(sig.length == 65, "bad sig length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 32))
            v := byte(0, calldataload(add(sig.offset, 64)))
        }
        return ecrecover(digest, v, r, s);
    }
}

contract ExerciseB_ReplayAttacker {
    function replay(
        ExerciseB_VulnerableClaims target,
        address payable recipient,
        uint256 amount,
        bytes32 salt,
        bytes calldata sig
    ) external {
        target.claim(recipient, amount, salt, sig);
        target.claim(recipient, amount, salt, sig);
    }
}
