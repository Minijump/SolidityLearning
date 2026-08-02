// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";

contract GovernorExample is GovernorSettings, GovernorCountingSimple {
    constructor()
        Governor("GovernorExample")
        GovernorSettings(1 /* 1 block */, 45818 /* 1 week */, 0)
    {}

    function clock() public view override returns (uint48) {
        return uint48(block.number);
    }

    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=blocknumber&from=default";
    }

    function quorum(uint256 /* blockNumber*/) public pure override returns (uint256) {
        return 4e18; // 4 tokens
    }

    function proposalThreshold()
        public
        pure
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return 50e18; // 10 tokens
    }

    function _getVotes(
        address account,
        uint256 blockNumber,
        bytes memory params
    ) internal view override returns (uint256) {
        account;
        blockNumber;
        params;
        if (account.balance >= 1 ether) {
            return 50e18; // 50 tokens for testing purposes
        } else {
            return 10e18; // 1 token for testing purposes
        }
    }
}
