// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "../../lib/forge-std/src/Test.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {TokenVault} from "../../src/ERC20/DemoVaultSafeERC20.sol";
import {MyToken} from "../../src/ERC20/DemoToken.sol";
import {NonCompliantToken} from "../../src/mocks/NonCompliantToken.sol";

contract TokenVaultTest is Test {
    TokenVault vault;
    MyToken compliantToken;
    NonCompliantToken nonCompliantToken;

    address alice = address(1);
    uint256 amount = 10 ether;

    function setUp() public {
        vault = new TokenVault();
        compliantToken = new MyToken();
        nonCompliantToken = new NonCompliantToken(1000 ether);

        compliantToken.transfer(alice, amount);
        nonCompliantToken.transfer(alice, amount);
        vm.startPrank(alice);
        compliantToken.approve(address(vault), amount);
        nonCompliantToken.approve(address(vault), amount);
        vm.stopPrank();
    }

    function testDepositCompliantToken() public {
        vm.prank(alice);
        vault.deposit(IERC20(address(compliantToken)), amount);

        assertEq(vault.balanceOf(address(compliantToken), alice), amount);
        assertEq(compliantToken.balanceOf(address(vault)), amount);
    }

    function testDepositNonCompliantToken() public {
        vm.prank(alice);
        vault.deposit(IERC20(address(nonCompliantToken)), amount);

        assertEq(vault.balanceOf(address(nonCompliantToken), alice), amount);
        assertEq(nonCompliantToken.balanceOf(address(vault)), amount);
    }

    // Calling the SAME non-compliant token through the plain IERC20 interface
    // reverts when the return value is used - not because the transfer
    // fails (the low-level call succeeds, as the trace shows), but because
    // Solidity reverts while decoding a bool out of empty return data. This
    // is the real-world USDT integration bug: `require(token.transfer(...))`
    // reverts even though the transfer itself would have worked.
    //
    // The revert happens in the CALLER's own frame right after the transfer
    // sub-call returns, not inside a new call frame, so vm.expectRevert()
    // (which watches the next call frame) can't see it directly on a bare
    // `IERC20(token).transfer(...)` statement. Routing the decode through an
    // external helper (_decodeReturnValue) call gives expectRevert a frame to catch.
    function _decodeReturnValue(IERC20 token, address to, uint256 value) external returns (bool) {
        bool success = token.transfer(to, value);
        return success;
    }

    function testPlainInterfaceCall_RevertsOnNonCompliantToken() public {
        vm.expectRevert();
        this._decodeReturnValue(IERC20(address(nonCompliantToken)), alice, amount);
    }
}
