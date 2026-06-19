// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableSignedClaims {
    address public immutable SIGNER;

    constructor(address trustedSigner) payable {
        SIGNER = trustedSigner;
    }

    // A "digest" is the hash of the message data that was signed off-chain.
    // The signer hashes (recipient, amount, salt, contract address) together, then signs it with their private key.
    // Vulnerability: nothing stops the same signature from being submitted again
    function claim(address payable recipient, uint256 amount, bytes32 salt, bytes calldata signature) public virtual {
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(this)));
        require(_recover(digest, signature) == SIGNER, "bad signature");

        (bool ok,) = recipient.call{value: amount}("");
        require(ok, "claim transfer failed");
    }

    // Recovers the signer address from a digest and a compact 65-byte signature.
    // A signature has three components packed as r (32 bytes) | s (32 bytes) | v (1 byte).
    // ecrecover is an EVM precompile: given the digest and (v, r, s) it derives
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

contract PatchedSignedClaims is VulnerableSignedClaims {
    mapping(bytes32 => bool) public usedDigests;

    constructor(address trustedSigner) VulnerableSignedClaims(trustedSigner) {}

    function claim(address payable recipient, uint256 amount, bytes32 salt, bytes calldata signature) public override {
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(this)));
        require(!usedDigests[digest], "already used");

        usedDigests[digest] = true;

        super.claim(recipient, amount, salt, signature);
    }
}

contract SignatureReplayAttacker {
    VulnerableSignedClaims public immutable TARGET;

    constructor(address targetAddress) {
        TARGET = VulnerableSignedClaims(targetAddress);
    }

    function attack(address payable recipient, uint256 amount, bytes32 salt, bytes calldata signature) external {
        TARGET.claim(recipient, amount, salt, signature);
        TARGET.claim(recipient, amount, salt, signature);
    }
}
