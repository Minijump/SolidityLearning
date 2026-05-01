// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableSignedClaims {
    address public immutable signer;

    constructor(address trustedSigner) payable {
        signer = trustedSigner;
    }

    function claim(address payable recipient, uint256 amount, bytes32 salt, bytes calldata signature) external {
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(this)));
        require(_recover(digest, signature) == signer, "bad signature");

        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "claim transfer failed");
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

contract FixedSignedClaims {
    address public immutable signer;
    mapping(bytes32 => bool) public usedDigests;

    constructor(address trustedSigner) payable {
        signer = trustedSigner;
    }

    function claim(address payable recipient, uint256 amount, bytes32 salt, bytes calldata signature) external {
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(this)));
        require(!usedDigests[digest], "already used");
        require(_recover(digest, signature) == signer, "bad signature");

        usedDigests[digest] = true;

        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "claim transfer failed");
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
