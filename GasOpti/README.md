# GasOpti

Short Foundry playground for common Solidity gas optimization patterns.

The goal is not to micro-optimize everything. It is to recognize the most common low-effort wins:

- prefer `calldata` over `memory` for read-only external inputs
- prefer custom errors over long revert strings
- use `unchecked` increments only when overflow is impossible
- pack storage values when they naturally fit in the same slot

## Structure

- `src/GasBasics.sol`: concise bad vs better examples
- `test/GasBasics.t.sol`: tiny comparisons you can run with gas reports

## Run It

```sh
forge test --match-path test/GasBasics.t.sol --gas-report
```

## Notes

- Gas numbers depend on compiler settings and surrounding code.
- Prefer readability first. Apply an optimization only when it is justified in context.
