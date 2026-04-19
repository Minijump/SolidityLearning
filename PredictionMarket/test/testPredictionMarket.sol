// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {PredictionMarket} from "../src/PredictionMarket.sol";


contract PredictionMarketTest is Test {
    PredictionMarket predictionMarket;
    address OWNER = makeAddr("owner");
    address ORACLE = makeAddr("oracle");
    address USER = makeAddr("user");

    function setUp() external {
        predictionMarket = new PredictionMarket{value: 10 ether}(
            OWNER,
            ORACLE,
            "test question, do you agree",
            1 ether,
            50,
            50
        );

        vm.deal(OWNER, 100 ether);
        vm.deal(USER, 100 ether);
    }

    function testAddLiquidity() external {
        uint256 initialEthCollateral = predictionMarket.s_ethCollateral();
        uint256 addedLiquidity = 1 ether;

        vm.startPrank(OWNER);
        predictionMarket.addLiquidity{value: addedLiquidity}();
        vm.stopPrank();

       assertEq(predictionMarket.s_ethCollateral(), initialEthCollateral + addedLiquidity);
    }

    function testAddLiquidityNotOwner() external {
        vm.startPrank(USER);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, USER));
        predictionMarket.addLiquidity{value: 1 ether}();
        vm.stopPrank();
    }

    function testAddLiquidityReported() external {
        vm.startPrank(ORACLE);
        predictionMarket.report(PredictionMarket.Outcome.NO);
        vm.stopPrank();

        vm.startPrank(OWNER);
        vm.expectRevert(PredictionMarket.PredictionMarket__PredictionAlreadyReported.selector);
        predictionMarket.addLiquidity{value: 1 ether}();
        vm.stopPrank();
    }

    function testReportYes() external {
        vm.startPrank(ORACLE);
        predictionMarket.report(PredictionMarket.Outcome.YES);
        vm.stopPrank();

        assertEq(address(predictionMarket.s_winningToken()), address(predictionMarket.i_yesToken()));
    }

    function testReportNo() external {
        vm.startPrank(ORACLE);
        predictionMarket.report(PredictionMarket.Outcome.NO);
        vm.stopPrank();

        assertEq(address(predictionMarket.s_winningToken()), address(predictionMarket.i_noToken()));
    }

    function testReportNotOracle() external {
        vm.startPrank(OWNER);
        vm.expectRevert(PredictionMarket.PredictionMarket__OnlyOracleCanReport.selector);
        predictionMarket.report(PredictionMarket.Outcome.YES);
        vm.stopPrank();
    }
}
