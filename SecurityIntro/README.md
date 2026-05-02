# SecurityIntro

This project is a Foundry-based Solidity security playground.

Each issue folder contains:

- a short explanation of the issue
- vulnerable code examples
- exploit code examples
- fixed versions

## Quick Start

### 1. Build everything

```sh
forge build
```

### 2. Run all tests

```sh
forge test
```

### 3. Run only one issue folder

```sh
forge test --match-path Reentrancy/ReentrancyExamples.t.sol -vvv
```
or 
```sh
forge test --match-path Reentrancy/\*.t.sol -vvv
```

## Do I need Anvil?

Not for the included tests. `forge test` runs against Foundry's in-memory local EVM.

Start `anvil` only if you want to:

- deploy contracts manually
- run `forge script --broadcast`
- inspect transactions from another terminal with `cast`

Example:

```sh
anvil
```

Then in another terminal:

```sh
forge script script/YourScript.s.sol:YourScript --rpc-url http://127.0.0.1:8545 --broadcast
```

## Notes

- The examples are intentionally minimal to keep the attack surface easy to reason about.
- Some bugs are historical, but they are still useful to learn because the underlying design mistake still matters.

## Suggested Study Order (by frequency and impact)

1. Reentrancy
2. Access control misconfiguration
3. Oracle manipulation
4. Signature replay and message-validation issues
5. Unchecked return values in external calls/token interactions
6. Denial of service patterns (unexpected revert, gas griefing)
7. Delegatecall and proxy storage-collision classes
8. Weak randomness
9. tx.origin phishing
10. Selfdestruct edge cases
11. Unchecked arithmetic (mainly when `unchecked` is misused in 0.8+)
