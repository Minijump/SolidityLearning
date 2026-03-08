// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1e18;

    function fundFundMe(address contractAdress) public {
        FundMe(payable(contractAdress)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe contract with %s ETH", SEND_VALUE / 1e18);
    }

    function run(address contractAdress) external {
        if (contractAdress == address(0)) {
            // address contractAdress = xxx; // Replace by Cainlink DevOpsTools method to get last deployed
            console.log("No contract address provided, using default %s", contractAdress);
        }
        vm.startBroadcast();
        fundFundMe(contractAdress);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        console.log("Withdraw FundMe balance!");
    }

    function run(address contractAdress) external {
        if (contractAdress == address(0)) {
            // address contractAdress = xxx; // Replace by Cainlink DevOpsTools method to get last deployed
            console.log("No contract address provided, using default %s", contractAdress);
        }
        vm.startBroadcast();
        withdrawFundMe(contractAdress);
        vm.stopBroadcast();
    }
}
