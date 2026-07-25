// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract OwnableExample is Ownable {
    // Ownable adds the following functions
    // transferOwnership(address newOwner),
    // renounceOwnership()
    // onlyOwner modifier
    uint256 public value;

    constructor() Ownable(msg.sender) {}

    function setValue(uint256 _value) public onlyOwner {
        value = _value;
    }

    function getValue() public view returns (uint256) {
        return value;
    }
}
