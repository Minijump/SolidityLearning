// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;


contract SubPlan {

    uint256 public subAmount;
    uint256 public subDuration;
    address public owner; //could use open zeppelin's Ownable, at first do it on our own
    bool public isOpen;

    mapping(address => uint256) public subPayments;

    constructor(uint256 _subAmount, uint256 _subDuration, address _owner) {
        subAmount = _subAmount;
        subDuration = _subDuration;
        owner = _owner;
        isOpen = true;
    }

    error InvalidSubscriptionAmount();
    error NotOwner();
    error SubscriptionPlanClosed();

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) {
            revert NotOwner();
        }
    }

    modifier OpenOnly() {
        _isOpen();
        _;
    }

    function _isOpen() internal view {
        if (!isOpen) {
            revert SubscriptionPlanClosed();
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

    function _subscribe() internal OpenOnly {
        if (msg.value != subAmount) {
            revert InvalidSubscriptionAmount();
        }
        subPayments[msg.sender] = block.timestamp;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function editSubAmount(uint256 newSubAmount) external onlyOwner {
        subAmount = newSubAmount;
    }

    function editSubDuration(uint256 newSubDuration) external onlyOwner {
        subDuration = newSubDuration;
    }

    function editOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function close() external onlyOwner {
        isOpen = false;
    }

    function open() external onlyOwner {
        isOpen = true;
    }

    function isSubscribed(address _subscriber) external view returns (bool) {
        uint256 subscriptionTime = subPayments[_subscriber];
        return subscriptionTime != 0 && block.timestamp < subscriptionTime + subDuration;
    }
}
