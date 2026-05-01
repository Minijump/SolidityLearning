# Reentrancy

## What It Is

Reentrancy happens when a contract makes an external call before it finishes updating its own internal state. If the callee can call back into the vulnerable contract, it may repeat the sensitive action multiple times while the contract still believes the old state is valid.

The usual shape is:

1. checks
2. external interaction
3. state update

That order is dangerous. The safer default is checks, effects, interactions.

## Why It Matters

Reentrancy can let an attacker drain Ether or tokens, bypass accounting, or execute logic multiple times in a single transaction.

## Example Set

- `ReentrancyExamples.sol`: vulnerable vault, exploit contract, and fixed vault
- `ReentrancyExamples.t.sol`: tests showing the break and the fix

## Learning Goals

- identify the external call that opens the door
- see why updating balances after sending Ether is unsafe
- recognize two standard mitigations: state-first accounting and reentrancy guards

## Key Defensive Pattern

Prefer this order:

1. validate inputs and permissions
2. update internal bookkeeping
3. perform the external call last

## Exercise Preview

See `Exercises.sol` for exploit-first and fix-first exercises.
