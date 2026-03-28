// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DEX} from "../src/DEX.sol";
import {Balloons} from "../src/Balloons.sol";

contract DeployBalloonsDEX is Script {
    function run() external returns (DEX, Balloons) {
        return run(msg.sender);
    }

    function run(address owner) public returns (DEX,Balloons) {
        vm.startBroadcast();
        Balloons newBalloons = new Balloons(owner);
        DEX newDex = new DEX(address(newBalloons));
        vm.stopBroadcast();
        return (newDex,newBalloons);
    }
}
