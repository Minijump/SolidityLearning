// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {MyToken} from "../../src/ERC20/DemoToken.sol";

contract MyTokenTest is Test {
    MyToken token;

    address alice = address(1);
    address bob = address(2);
    address smartContract = address(3);

    uint256 initialSupply = 1000 ether;
    uint256 initialBalance = 100 ether;
    uint256 thisBalance = 700 ether;

    function setUp() public {
        token = new MyToken();
        token.transfer(alice, initialBalance);
        token.transfer(bob, initialBalance);
        token.transfer(smartContract, initialBalance);
    }

    // Test view after deployment ----------------------------------------------------------------------------
    function testName() public view {
        assertEq(token.name(), "My Token");
    }

    function testSymbol() public view {
        assertEq(token.symbol(), "MTK");
    }

    function testDecimals() public view {
        assertEq(token.decimals(), 18);
    }

    function testTotalSupply() public view {
        assertEq(token.totalSupply(), initialSupply);
    }

    function testInitialBalanceOfDeployer() public view {
        assertEq(token.balanceOf(address(this)), thisBalance);
    }

    // Test actions-----------------------------------------------------------------------------------------
    function testTransfer() public {
        uint256 amount = 10 ether;
        
        vm.prank(alice);
        token.transfer(bob, amount);

        assertEq(token.balanceOf(alice), initialBalance - amount);
        assertEq(token.balanceOf(bob), initialBalance + amount);
    }


    function testApprove() public {
        uint256 amount = 10 ether;

        vm.prank(alice);
        token.approve(smartContract, amount);

        assertEq(token.allowance(alice, smartContract), amount);
    }


    function testTransferFrom() public {
        uint256 amount = 10 ether;
        vm.prank(alice);
        token.approve(smartContract, amount);

        vm.prank(smartContract);
        token.transferFrom(alice, bob, amount);

        assertEq(token.balanceOf(bob), initialBalance + amount);
        assertEq(token.balanceOf(alice), initialBalance - amount);
        assertEq(token.allowance(alice, smartContract), 0);
    }

    function testRevokeApproval() public {
        uint256 amount = 200 ether;
        vm.prank(alice);
        token.approve(smartContract, amount);

        vm.prank(alice);
        token.approve(smartContract, 0);

        assertEq(token.allowance(alice, smartContract), 0);
    }
}
