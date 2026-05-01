// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {
    HonestToken,
    AlwaysFalseToken,
    VulnerableTokenShop,
    FixedTokenShop
} from "./UncheckedReturnValueExamples.sol";

contract UncheckedReturnValueExamplesTest is Test {
    address internal buyer = makeAddr("buyer");
    address internal treasury = makeAddr("treasury");

    function testIgnoringFalseReturnLetsBuyerGetItemForFree() external {
        AlwaysFalseToken token = new AlwaysFalseToken();
        VulnerableTokenShop shop = new VulnerableTokenShop(address(token), treasury);

        vm.prank(buyer);
        shop.purchase();

        assertTrue(shop.hasItem(buyer));
        assertEq(token.balanceOf(treasury), 0);
    }

    function testCheckingReturnValueRejectsFailedPayment() external {
        AlwaysFalseToken token = new AlwaysFalseToken();
        FixedTokenShop shop = new FixedTokenShop(address(token), treasury);

        vm.expectRevert();
        vm.prank(buyer);
        shop.purchase();

        assertFalse(shop.hasItem(buyer));
    }

    function testFixedShopStillWorksWithHonestToken() external {
        HonestToken token = new HonestToken();
        FixedTokenShop shop = new FixedTokenShop(address(token), treasury);

        token.mint(buyer, 200);

        vm.startPrank(buyer);
        token.approve(address(shop), 100);
        shop.purchase();
        vm.stopPrank();

        assertTrue(shop.hasItem(buyer));
        assertEq(token.balanceOf(treasury), 100);
        assertEq(token.balanceOf(buyer), 100);
    }
}