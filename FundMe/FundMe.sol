// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 3000 * 1e18;
    address[] public funders;
    mapping(address funders => uint256 amountFunded) public adressToAmountFunded;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Should send at least one eth, these words increase gas, these one too, ...");
        funders.push(msg.sender);
        adressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 fundersIndex = 0; fundersIndex < funders.length; fundersIndex++){
            address funder = funders[fundersIndex];
            adressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable { 
        fund();
    }
}
