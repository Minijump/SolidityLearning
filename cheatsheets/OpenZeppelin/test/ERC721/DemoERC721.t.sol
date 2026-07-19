// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {MyNFT} from "../../src/ERC721/DemoERC721.sol";

contract DemoERC721Test is Test {
    MyNFT public myNFT;
    address public owner = address(1);
    address public addr1 = address(2);
    address public contractAddress = address(3);

    function setUp() public {
        vm.startPrank(owner);
        myNFT = new MyNFT();
        vm.stopPrank();
    }

    function testInitialSupply() public view{
        assertEq(myNFT.balanceOf(owner), 2);
        assertEq(myNFT.ownerOf(1), owner);
        assertEq(myNFT.ownerOf(2), owner);
    }

    function testTransfer() public {
        vm.prank(owner);
        myNFT.transferFrom(owner, addr1, 1);

        assertEq(myNFT.balanceOf(owner), 1);
        assertEq(myNFT.balanceOf(addr1), 1);
        assertEq(myNFT.ownerOf(1), addr1);
        assertEq(myNFT.ownerOf(2), owner);
    }

    function testTransferFrom() public {
        vm.prank(owner);
        myNFT.approve(contractAddress, 1);

        vm.prank(contractAddress);
        myNFT.transferFrom(owner, addr1, 1);

        assertEq(myNFT.balanceOf(owner), 1);
        assertEq(myNFT.balanceOf(addr1), 1);
        assertEq(myNFT.ownerOf(1), addr1);
    }

    function testTransferFromWithoutApproval() public {
        vm.prank(owner);
        myNFT.approve(contractAddress, 2); // approve token 2

        vm.prank(contractAddress);
        vm.expectRevert();
        myNFT.transferFrom(owner, addr1, 1); // try to transfer token 1
    }

    function testTransferAllTokens() public {
        // While 'approve' enables transferFrom for a specific token, 
        // 'setApprovalForAll' enables transferFrom for all tokens of the owner.
        vm.prank(owner);
        myNFT.setApprovalForAll(contractAddress, true);

        vm.startPrank(contractAddress);
        myNFT.transferFrom(owner, addr1, 1);
        myNFT.transferFrom(owner, addr1, 2);
        vm.stopPrank();

        assertEq(myNFT.balanceOf(owner), 0);
        assertEq(myNFT.balanceOf(addr1), 2);
        assertEq(myNFT.ownerOf(1), addr1);
        assertEq(myNFT.ownerOf(2), addr1);
    }
}
