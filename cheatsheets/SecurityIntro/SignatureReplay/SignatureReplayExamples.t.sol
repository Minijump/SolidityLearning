// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {VulnerableSignedClaims, PatchedSignedClaims, SignatureReplayAttacker} from "./SignatureReplayExamples.sol";

contract SignatureReplayExamplesTest is Test {
    uint256 internal signerPk = 0xA11CE;
    address internal signer = vm.addr(signerPk);
    address payable internal recipient = payable(makeAddr("recipient"));

    VulnerableSignedClaims internal vulnerableClaims;
    PatchedSignedClaims internal patchedClaims;

    uint256 internal constant VAULT_BALANCE = 5 ether;
    uint256 internal constant CLAIM_AMOUNT = 1 ether;

    function setUp() external {
        vulnerableClaims = new VulnerableSignedClaims(signer);
        patchedClaims = new PatchedSignedClaims(signer);
        vm.deal(address(vulnerableClaims), VAULT_BALANCE);
        vm.deal(address(patchedClaims), VAULT_BALANCE);
    }

    function _signDigest(bytes32 digest) internal view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        return abi.encodePacked(r, s, v);
    }

    function testExploit() external {
        SignatureReplayAttacker attacker = new SignatureReplayAttacker(address(vulnerableClaims));

        bytes32 salt = keccak256("claim-1");
        bytes32 digest = keccak256(abi.encodePacked(recipient, CLAIM_AMOUNT, salt, address(vulnerableClaims)));
        bytes memory sig = _signDigest(digest);

        attacker.attack(recipient, CLAIM_AMOUNT, salt, sig);

        assertEq(recipient.balance, 2 ether);
        assertEq(address(vulnerableClaims).balance, VAULT_BALANCE - 2 ether);
    }

    function testLegitimateClaimOnPatchedContract() external {
        bytes32 salt = keccak256("claim-1");
        bytes32 digest = keccak256(abi.encodePacked(recipient, CLAIM_AMOUNT, salt, address(patchedClaims)));
        bytes memory sig = _signDigest(digest);

        patchedClaims.claim(recipient, CLAIM_AMOUNT, salt, sig);

        assertEq(recipient.balance, CLAIM_AMOUNT);
        assertEq(address(patchedClaims).balance, VAULT_BALANCE - CLAIM_AMOUNT);
    }

    function testReplayBlockedOnPatchedContract() external {
        SignatureReplayAttacker attacker = new SignatureReplayAttacker(address(patchedClaims));
        bytes32 salt = keccak256("claim-1");
        bytes32 digest = keccak256(abi.encodePacked(recipient, CLAIM_AMOUNT, salt, address(patchedClaims)));
        bytes memory sig = _signDigest(digest);

        vm.expectRevert();
        attacker.attack(recipient, CLAIM_AMOUNT, salt, sig);

        assertEq(recipient.balance, 0);
        assertEq(address(patchedClaims).balance, VAULT_BALANCE);
    }
}
