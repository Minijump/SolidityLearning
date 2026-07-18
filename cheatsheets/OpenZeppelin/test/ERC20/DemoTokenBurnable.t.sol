// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {MyBurnableToken} from "../../src/ERC20/DemoTokenBurnable.sol";

contract MyBurnableTokenTest is Test {
    MyBurnableToken token;

    address alice = address(1);
    address bob = address(2);
    address smartContract = address(3);

    uint256 initialSupply = 1000 ether;
    uint256 initialBalance = 100 ether;
    uint256 thisBalance = 700 ether;

    function setUp() public {
        token = new MyBurnableToken();
        token.transfer(alice, initialBalance);
        token.transfer(bob, initialBalance);
        token.transfer(smartContract, initialBalance);
    }

    function testBurn() public {
        vm.startPrank(alice);
        token.burn(50 ether);

        assertEq(token.balanceOf(alice), initialBalance - 50 ether);
        assertEq(token.totalSupply(), initialSupply - 50 ether);
        vm.stopPrank();
    }

    function testBurnFrom() public {
        vm.startPrank(alice);
        token.approve(smartContract, 50 ether);
        vm.stopPrank();

        vm.startPrank(smartContract);
        token.burnFrom(alice, 50 ether);

        assertEq(token.balanceOf(alice), initialBalance - 50 ether);
        assertEq(token.totalSupply(), initialSupply - 50 ether);
        vm.stopPrank();
    }
}
