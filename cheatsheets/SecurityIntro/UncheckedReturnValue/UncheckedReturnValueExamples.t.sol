// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    VulnerableTokenShop,
    PatchedTokenShop,
    TokenShopAttacker
} from "./UncheckedReturnValueExamples.sol";

contract UncheckedReturnValueExamplesTest is Test {
    address internal treasury = makeAddr("treasury");
    VulnerableTokenShop internal vulnerableShop;
    PatchedTokenShop internal patchedShop;

    function setUp() external {
        vulnerableShop = new VulnerableTokenShop(treasury);
        patchedShop = new PatchedTokenShop(treasury);
    }

    function testExploitVulnerableShop() external {
        TokenShopAttacker attacker = new TokenShopAttacker(address(vulnerableShop));

        attacker.attack();

        assertTrue(vulnerableShop.hasItem(address(attacker)));
    }

    function testCannotExploitPatchedShop() external {
        TokenShopAttacker attacker = new TokenShopAttacker(address(patchedShop));

        vm.expectRevert();
        attacker.attack();

        assertFalse(patchedShop.hasItem(address(attacker)));
    }
}