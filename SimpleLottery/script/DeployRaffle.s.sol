// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    function run() public returns (Raffle) {
        uint256 entranceFee = 0.1 ether;
        uint256 interval = 30;
        vm.startBroadcast();
        Raffle raffle = new Raffle(entranceFee, interval);
        vm.stopBroadcast();
        return raffle;
    }
}
