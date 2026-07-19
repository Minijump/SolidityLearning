// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    constructor() ERC721("My NFT", "MNFT") {
        _mint(msg.sender, 1);
        _mint(msg.sender, 2);
    }

    // Public functions are:
    //  - view: symbol(), balanceOf(address owner), ownerOf(uint256 tokenId), isApprovedForAll(address owner, address operator)
    //  - actions: - safeTransferFrom(address from, address to, uint256 tokenId)
    //             - setApprovalForAll(address operator, bool approved)
    // ...
}
