// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./MyUSDStaking.sol";

error Engine__InvalidBorrowRate();
error RateController__AlreadyInitialized();
error RateController__InvalidAddress();

contract RateController {
    IMyUSDEngine private i_myUSD;
    MyUSDStaking private i_staking;

    constructor(address _myUSD) {
        require(_myUSD != address(0), "Invalid MyUSD address");
        i_myUSD = IMyUSDEngine(_myUSD);
    }

    /// @notice Set the staking contract address (only once)
    function setStaking(address _staking) external {
        if (address(i_staking) != address(0)) revert RateController__AlreadyInitialized();
        if (_staking == address(0)) revert RateController__InvalidAddress();
        i_staking = MyUSDStaking(_staking);
    }

    /**
     * @notice Set the borrow rate for the MyUSD engine
     * @param newRate The new borrow rate to set
     */
    function setBorrowRate(uint256 newRate) external {
        try i_myUSD.setBorrowRate(newRate) {} catch {
            revert Engine__InvalidBorrowRate();
        }
    }

    /**
     * @notice Set the savings rate for the MyUSD staking contract
     * @param newRate The new savings rate to set
     */
    function setSavingsRate(uint256 newRate) external {
        try i_staking.setSavingsRate(newRate) {} catch {
            revert Staking__InvalidSavingsRate();
        }
    }
}
