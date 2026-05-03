# Weak Randomness

## What It Is

On-chain values such as `block.timestamp`, `block.number`, `blockhash`, and `block.prevrandao` are not secret from contracts in the same transaction. If your game relies on them directly, an attacker can often predict the outcome before placing the bet.

## Why It Matters

Predictable randomness lets attackers win games, lotteries, and reward systems with little or no risk.

## Safer Rule

Do not treat current-block values as secret randomness. Use commit-reveal, an oracle such as Chainlink VRF, or another design where the attacker cannot know the result when committing.
-> Best to use oracle
-> n-party commit-reveal can also matches some use cases: parties all commit a hash, in reveal phase they reveal the secret. The contract checks that secrets and hash matches, than it compute a random value based on this.
