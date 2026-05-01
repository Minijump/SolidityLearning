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

## Key Defensive Pattern

Prefer this order (Check Effect Integration pattern):

1. validate inputs and permissions
2. update internal bookkeeping
3. perform the external call last
