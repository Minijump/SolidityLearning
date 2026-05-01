# Weak Randomness

## What It Is

On-chain values such as `block.timestamp`, `block.number`, `blockhash`, and `block.prevrandao` are not secret from contracts in the same transaction. If your game relies on them directly, an attacker can often predict the outcome before placing the bet.

## Why It Matters

Predictable randomness lets attackers win games, lotteries, and reward systems with little or no risk.

## Example Set

- `WeakRandomnessExamples.sol`: predictable betting game, predictor contract, and a commit-reveal redesign
- `WeakRandomnessExamples.t.sol`: tests showing the prediction attack and the safer pattern

## Safer Rule

Do not treat current-block values as secret randomness. Use commit-reveal, an oracle such as Chainlink VRF, or another design where the attacker cannot know the result when committing.
