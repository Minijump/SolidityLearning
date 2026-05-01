// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IExerciseToken {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/*
Exercise Type A (write exploit):
A1: Use a token that returns false and still get marked as paid.
A2: Adapt to a low-level call path that ignores success.
*/
contract ExerciseA_AlwaysFalseToken is IExerciseToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract ExerciseA_VulnerableShop {
    IExerciseToken public immutable TOKEN;
    address public immutable TREASURY;
    mapping(address => bool) public purchased;

    constructor(address tokenAddress, address treasuryAddress) {
        TOKEN = IExerciseToken(tokenAddress);
        TREASURY = treasuryAddress;
    }

    function buy() external {
        TOKEN.transferFrom(msg.sender, TREASURY, 100);
        purchased[msg.sender] = true;
    }
}

/*
Exercise Type B (write fix):
Vulnerable shop + failing token are provided. Patch shop only.
*/
contract ExerciseB_AlwaysFalseToken is IExerciseToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract ExerciseB_VulnerableShop {
    IExerciseToken public immutable TOKEN;
    address public immutable TREASURY;
    mapping(address => bool) public purchased;

    constructor(address tokenAddress, address treasuryAddress) {
        TOKEN = IExerciseToken(tokenAddress);
        TREASURY = treasuryAddress;
    }

    function buy() external {
        TOKEN.transferFrom(msg.sender, TREASURY, 100);
        purchased[msg.sender] = true;
    }
}

contract ExerciseB_FreeBuyer {
    function exploit(ExerciseB_VulnerableShop shop) external {
        shop.buy();
    }
}
