// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract LogicV1 {
    address public owner;
    uint256 public someValue;

    function setOwner(address newOwner) external {
        owner = newOwner;
    }

    function setValue(uint256 newValue) external {
        someValue = newValue;
    }
}

contract MaliciousLogic {
    function rug(address payable thief) external {
        (bool ok,) = thief.call{value: address(this).balance}("");
        require(ok, "rug failed");
    }
}

contract VulnerableProxy {
    address public implementation;
    address public proxyAdmin;

    constructor(address impl) {
        implementation = impl;
        proxyAdmin = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {
        _delegate(implementation);
    }

    function _delegate(address impl) internal {
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

contract FixedProxy {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("securityintro.fixedproxy.implementation")) - 1);
    address public immutable PROXY_ADMIN;

    constructor(address impl) {
        PROXY_ADMIN = msg.sender;
        _setImplementation(impl);
    }

    function upgradeTo(address newImpl) external {
        require(msg.sender == PROXY_ADMIN, "not admin");
        _setImplementation(newImpl);
    }

    receive() external payable {}

    fallback() external payable {
        _delegate(_implementation());
    }

    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address impl) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, impl)
        }
    }

    function _delegate(address impl) internal {
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
