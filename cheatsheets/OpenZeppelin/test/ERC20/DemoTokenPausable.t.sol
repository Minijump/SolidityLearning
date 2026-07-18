// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {MyPausableToken} from "../../src/ERC20/DemoTokenPausable.sol";

contract MyPausableTokenTest is Test {
    MyPausableToken token;

    address alice = address(1);
    address bob = address(2);

    uint256 initialSupply = 1000 ether;
    uint256 initialBalance = 100 ether;
    uint256 thisBalance = 700 ether;

    function setUp() public {
        token = new MyPausableToken();
        token.transfer(alice, initialBalance);
        token.transfer(bob, initialBalance);
    }

    function testPause() public {
        vm.prank(alice);
        token.pause();

        vm.expectRevert();
        vm.prank(alice);
        token.transfer(bob, 10 ether);
        vm.assertEq(token.balanceOf(alice), initialBalance);
    }

    function testUnpause() public {
        uint256 transferAmount = 10 ether;
        vm.prank(alice);
        token.pause();

        vm.prank(alice);
        token.unpause();

        vm.prank(alice);
        token.transfer(bob, transferAmount);
        vm.assertEq(token.balanceOf(alice), initialBalance - transferAmount);
        vm.assertEq(token.balanceOf(bob), initialBalance + transferAmount);
    }
}
