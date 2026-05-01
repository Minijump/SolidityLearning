// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
Exercise Type A (write exploit):
A1: Manipulate spot price then over-borrow.
A2: Do the same when protocol uses two spot sources and picks max().
*/
contract ExerciseA_Oracle {
    uint256 public priceE18 = 1800e18;

    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract ExerciseA_Lending {
    ExerciseA_Oracle public immutable ORACLE;
    mapping(address => uint256) public collateralEth;
    mapping(address => uint256) public debtEth;

    constructor(address oracleAddress) payable {
        ORACLE = ExerciseA_Oracle(oracleAddress);
    }

    function depositCollateral() external payable {
        collateralEth[msg.sender] += msg.value;
    }

    function borrow(uint256 amountEth) external {
        uint256 maxDebt = (collateralEth[msg.sender] * ORACLE.priceE18()) / 3600e18;
        require(debtEth[msg.sender] + amountEth <= maxDebt, "insufficient collateral");
        debtEth[msg.sender] += amountEth;
        (bool ok,) = payable(msg.sender).call{value: amountEth}("");
        require(ok, "transfer failed");
    }
}

/*
Exercise Type B (write fix):
A known manipulation path exists. Patch oracle usage only.
*/
contract ExerciseB_VulnerableOracle {
    uint256 public priceE18 = 1800e18;

    function setPrice(uint256 newPriceE18) external {
        priceE18 = newPriceE18;
    }
}

contract ExerciseB_VulnerableLending {
    ExerciseB_VulnerableOracle public immutable ORACLE;
    mapping(address => uint256) public collateralEth;

    constructor(address oracleAddress) payable {
        ORACLE = ExerciseB_VulnerableOracle(oracleAddress);
    }

    function depositCollateral() external payable {
        collateralEth[msg.sender] += msg.value;
    }

    function borrow(uint256 amountEth) external {
        uint256 maxDebt = (collateralEth[msg.sender] * ORACLE.priceE18()) / 3600e18;
        require(amountEth <= maxDebt, "too much");
        (bool ok,) = payable(msg.sender).call{value: amountEth}("");
        require(ok, "transfer failed");
    }
}

contract ExerciseB_ManipulationAttacker {
    function attack(
        ExerciseB_VulnerableOracle oracle,
        ExerciseB_VulnerableLending lending,
        uint256 fakePrice,
        uint256 borrowAmount
    ) external payable {
        lending.depositCollateral{value: msg.value}();
        oracle.setPrice(fakePrice);
        lending.borrow(borrowAmount);
    }
}
