// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MyUSDEngine} from "../src/MyUSDEngine.sol";
import {Oracle} from "../src/Oracle.sol";
import {MyUSDStaking} from "../src/MyUSDStaking.sol";
import {RateController} from "../src/RateController.sol";
import {MyUSD} from "../src/MyUSD.sol";
import {DEX} from "../src/DEX.sol";

contract DeployMyUSD is Script {
    function run() public returns (MyUSDEngine) {
        vm.startBroadcast();
        MyUSD myUSD = new MyUSD();
        DEX dex = new DEX(address(myUSD));
        Oracle oracle = new Oracle(address(dex), 2000 ether); // Default price of $2000 for ETH
        RateController rateController = new RateController(address(myUSD));
        MyUSDStaking staking = new MyUSDStaking(address(myUSD), address(rateController));
        
        MyUSDEngine newMyUSDEngine = new MyUSDEngine(
            address(oracle),
            address(myUSD),
            address(staking),
            address(rateController)
        );
        
        rateController.setStaking(address(staking));
        myUSD.setEngineContract(address(newMyUSDEngine));
        myUSD.setStakingContract(address(staking));
        staking.setEngine(address(newMyUSDEngine));
        
        vm.stopBroadcast();
        return newMyUSDEngine;
    }
}
