// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


contract SubPlan {

    uint256 public subAmount;
    uint256 public subDuration;
    address public owner; //could use open zeppelin's Ownable, at first do it on our own

    constructor(uint256 _subAmount, uint256 _subDuration, address _owner) {
        subAmount = _subAmount;
        subDuration = _subDuration;
        owner = _owner;
    }
}
