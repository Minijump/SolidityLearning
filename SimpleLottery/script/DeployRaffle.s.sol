// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    function run() external {
        uint256 entranceFee = 0.1 ether;
        uint256 interval = 30;
        vm.startBroadcast();
        new Raffle(entranceFee, interval);
        vm.stopBroadcast();
    }
}
