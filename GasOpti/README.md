# GasOpti

Short Foundry playground for common Solidity gas optimization patterns. The goal is not to micro-optimize everything. It is to recognize the most common low-effort wins:

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
