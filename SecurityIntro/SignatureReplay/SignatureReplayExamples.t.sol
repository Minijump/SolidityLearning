// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {VulnerableSignedClaims, FixedSignedClaims} from "./SignatureReplayExamples.sol";

contract SignatureReplayExamplesTest is Test {
    uint256 internal signerPk = 0xA11CE;
    address internal signer = vm.addr(signerPk);
    address payable internal recipient = payable(makeAddr("recipient"));

    function testSameSignatureCanBeReplayedOnVulnerableContract() external {
        VulnerableSignedClaims claims = new VulnerableSignedClaims(signer);
        vm.deal(address(claims), 5 ether);

        uint256 amount = 1 ether;
        bytes32 salt = keccak256("claim-1");
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(claims)));
        bytes memory sig = _signDigest(digest);

        claims.claim(recipient, amount, salt, sig);
        claims.claim(recipient, amount, salt, sig);

        assertEq(recipient.balance, 2 ether);
        assertEq(address(claims).balance, 3 ether);
    }

    function testReplayIsBlockedOnFixedContract() external {
        FixedSignedClaims claims = new FixedSignedClaims(signer);
        vm.deal(address(claims), 5 ether);

        uint256 amount = 1 ether;
        bytes32 salt = keccak256("claim-1");
        bytes32 digest = keccak256(abi.encodePacked(recipient, amount, salt, address(claims)));
        bytes memory sig = _signDigest(digest);

        claims.claim(recipient, amount, salt, sig);

        vm.expectRevert();
        claims.claim(recipient, amount, salt, sig);

        assertEq(recipient.balance, 1 ether);
        assertEq(address(claims).balance, 4 ether);
    }

    function _signDigest(bytes32 digest) internal view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        return abi.encodePacked(r, s, v);
    }
}
