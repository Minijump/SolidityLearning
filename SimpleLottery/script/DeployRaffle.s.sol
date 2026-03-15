// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    function run() public returns (Raffle) {
        return run(0.1 ether, 30);
    }

    function run(uint256 entranceFee, uint256 interval) public returns (Raffle) {
        vm.startBroadcast();
        Raffle raffle = new Raffle(entranceFee, interval);
        vm.stopBroadcast();
        return raffle;
    }
}
