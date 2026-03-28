// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DEX} from "../src/DEX.sol";
import {Balloons} from "../src/Balloons.sol";

contract DeployBalloonsDEX is Script {
    function run() external returns (DEX) {
        vm.startBroadcast();
        Balloons newBalloons = new Balloons();
        DEX newDex = new DEX(address(newBalloons));
        vm.stopBroadcast();
        return newDex;
    }
}
