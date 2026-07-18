// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ERC20Pausable} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract MyPausableToken is ERC20, ERC20Pausable {
    constructor() ERC20("My Pausable Token", "MPTK") {
        _mint(msg.sender, 1000 ether);
    }
    // private functions added are: 
    //      - _pause() - to pause the contract (via the Pausable contract)
    //      - _unpause() - to unpause the contract (via the Pausable contract)
    //      - _update is overridden to include the whenNotPaused modifier, which ensures that token transfers can only occur when the contract is not paused. ATTENTION it should also be overriden here
    // public functions pause and unpause should be added here

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
