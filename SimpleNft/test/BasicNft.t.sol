// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {Test, console2} from "forge-std/Test.sol";

contract BasicNftTest is Test {
    string constant NFT_NAME = "Dogie";
    string constant NFT_SYMBOL = "DOG";
    BasicNft public basicNft;
    DeployBasicNft public deployer;
    address public deployerAddress;

    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    address public constant USER = address(1);

    function setUp() public {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    function testInitializedCorrectly() public view {
        // assert(keccak256(abi.encodePacked(basicNft.name())) == keccak256(abi.encodePacked((NFT_NAME))));
        // assert(keccak256(abi.encodePacked(basicNft.symbol())) == keccak256(abi.encodePacked((NFT_SYMBOL))));
        assertEq(basicNft.name(), NFT_NAME);
        assertEq(basicNft.symbol(), NFT_SYMBOL);
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        basicNft.mintNft(PUG_URI);

        assertEq(basicNft.balanceOf(USER), 1);
    }

    function testTokenURIIsCorrect() public {
        vm.prank(USER);
        basicNft.mintNft(PUG_URI);

        assertEq(basicNft.tokenURI(0), PUG_URI);
    }
}
