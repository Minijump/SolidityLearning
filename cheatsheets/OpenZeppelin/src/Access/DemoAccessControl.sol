// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract AccessControlExample is AccessControl {
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    uint256 public value;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setValue(uint256 _value) public onlyRole(DEFAULT_ADMIN_ROLE) {
        value = _value;
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    function grantUserRole(address user) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(USER_ROLE, user);
    }

    function revokeUserRole(address user) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(USER_ROLE, user);
    }

    function hasUserRole(address user) public view returns (bool) {
        return hasRole(USER_ROLE, user);
    }

    function functionOnlyForUserRole() public view onlyRole(USER_ROLE) returns (string memory) {
        return "Hello User";
    }
}