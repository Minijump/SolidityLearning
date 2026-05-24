// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


contract SubPlan {

    uint256 public subAmount;
    uint256 public subDuration;
    address public owner; //could use open zeppelin's Ownable, at first do it on our own

    mapping(address => uint256) public subPayments;

    constructor(uint256 _subAmount, uint256 _subDuration, address _owner) {
        subAmount = _subAmount;
        subDuration = _subDuration;
        owner = _owner;
    }

    error InvalidSubscriptionAmount();
    error NotOwner();

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) {
            revert NotOwner();
        }
    }

    receive() external payable {
        _subscribe();
    }

    fallback() external payable {
        _subscribe();
    }

    function subscribe() external payable {
        _subscribe();
    }

    function _subscribe() internal {
        if (msg.value != subAmount) {
            revert InvalidSubscriptionAmount();
        }
        subPayments[msg.sender] = block.timestamp;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function isSubscribed(address _subscriber) external view returns (bool) {
        uint256 subscriptionTime = subPayments[_subscriber];
        return subscriptionTime != 0 && block.timestamp < subscriptionTime + subDuration;
    }
}
