// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MyUSDEngine} from "../src/MyUSDEngine.sol";
import {DeployMyUSDEngine} from "../script/DeployMyUSDEngine.s.sol";


contract DEXTest is Test {
    MyUSDEngine myUSDEngine;

    function setUp() external {
        DeployMyUSDEngine deployer = new DeployMyUSDEngine();
        myUSDEngine = deployer.run();
    }

    function testDeployment() external view{
        assert(address(myUSDEngine) != address(0));
    }
}
