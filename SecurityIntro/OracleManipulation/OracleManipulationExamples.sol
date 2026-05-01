// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableSpotOracle {
    uint256 public priceE18 = 2000e18;

    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract VulnerableLending {
    VulnerableSpotOracle public immutable oracle;
    mapping(address => uint256) public collateralEth;
    mapping(address => uint256) public debtEth;

    constructor(address oracleAddress) payable {
        oracle = VulnerableSpotOracle(oracleAddress);
    }

    function depositCollateral() external payable {
        collateralEth[msg.sender] += msg.value;
    }

    function borrow(uint256 amountEth) external {
        uint256 maxDebt = (collateralEth[msg.sender] * oracle.priceE18()) / 4000e18;
        require(debtEth[msg.sender] + amountEth <= maxDebt, "insufficient collateral");

        debtEth[msg.sender] += amountEth;
        (bool ok,) = payable(msg.sender).call{value: amountEth}("");
        require(ok, "borrow transfer failed");
    }

    function fundPool() external payable {}
}

contract FixedTrustedOracle {
    uint256 public priceE18 = 2000e18;
    address public immutable owner;

    constructor(address oracleOwner) {
        owner = oracleOwner;
    }

    function setPrice(uint256 newPriceE18) external {
        require(msg.sender == owner, "not owner");
        priceE18 = newPriceE18;
    }
}

contract FixedLending {
    FixedTrustedOracle public immutable oracle;
    mapping(address => uint256) public collateralEth;
    mapping(address => uint256) public debtEth;

    constructor(address oracleAddress) payable {
        oracle = FixedTrustedOracle(oracleAddress);
    }

    function depositCollateral() external payable {
        collateralEth[msg.sender] += msg.value;
    }

    function borrow(uint256 amountEth) external {
        uint256 maxDebt = (collateralEth[msg.sender] * oracle.priceE18()) / 4000e18;
        require(debtEth[msg.sender] + amountEth <= maxDebt, "insufficient collateral");

        debtEth[msg.sender] += amountEth;
        (bool ok,) = payable(msg.sender).call{value: amountEth}("");
        require(ok, "borrow transfer failed");
    }

    function fundPool() external payable {}
}
