// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableSpotOracle {
    uint256 public priceE18 = 2000e18;

    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract VulnerableLending {
    VulnerableSpotOracle public immutable ORACLE;
    mapping(address => uint256) public collateralEth;
    mapping(address => uint256) public debtEth;

    constructor(address oracleAddress) payable {
        ORACLE = VulnerableSpotOracle(oracleAddress);
    }

    function depositCollateral() external payable {
        collateralEth[msg.sender] += msg.value;
    }

    function borrow(uint256 amountEth) external {
        uint256 maxDebt = (collateralEth[msg.sender] * ORACLE.priceE18()) / 4000e18;
        require(debtEth[msg.sender] + amountEth <= maxDebt, "insufficient collateral");

        debtEth[msg.sender] += amountEth;
        (bool ok,) = payable(msg.sender).call{value: amountEth}("");
        require(ok, "borrow transfer failed");
    }

    function fundPool() external payable {}
}

contract FixedTrustedOracle {
    uint256 public priceE18 = 2000e18;
    address public immutable OWNER;

    constructor(address oracleOwner) {
        OWNER = oracleOwner;
    }

    function setPrice(uint256 newPriceE18) external {
        require(msg.sender == OWNER, "not owner");
        priceE18 = newPriceE18;
    }
}

contract FixedLending {
    FixedTrustedOracle public immutable ORACLE;
    mapping(address => uint256) public collateralEth;
    mapping(address => uint256) public debtEth;

    constructor(address oracleAddress) payable {
        ORACLE = FixedTrustedOracle(oracleAddress);
    }

    function depositCollateral() external payable {
        collateralEth[msg.sender] += msg.value;
    }

    function borrow(uint256 amountEth) external {
        uint256 maxDebt = (collateralEth[msg.sender] * ORACLE.priceE18()) / 4000e18;
        require(debtEth[msg.sender] + amountEth <= maxDebt, "insufficient collateral");

        debtEth[msg.sender] += amountEth;
        (bool ok,) = payable(msg.sender).call{value: amountEth}("");
        require(ok, "borrow transfer failed");
    }

    function fundPool() external payable {}
}
