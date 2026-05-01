# Selfdestruct Edge Cases

## What It Is

Any contract can receive ETH via `selfdestruct`, even if it has no payable function. Designs that assume balance only changes through controlled functions can break.

## Why It Matters

Forced ETH can break invariants and trigger denial of service or accounting errors.

## Example Set

- `SelfdestructEdgeCasesExamples.sol`: vulnerable invariant-based bank, force-sender, and fixed accounting-first bank
- `SelfdestructEdgeCasesExamples.t.sol`: tests showing forced-ETH DoS and the fix

## Safer Rule

Never rely on `address(this).balance` alone as your trusted accounting source.
