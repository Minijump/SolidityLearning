# SecurityIntro

This project is a Foundry-based Solidity security playground.

Each issue folder contains:

- a short explanation of the issue
- vulnerable code examples
- exploit code examples
- fixed versions
- `Exercises.sol` with starter contracts where you write the exploit or write the fix

## Layout

- `Reentrancy/`
- `TxOriginPhishing/`
- `ArithmeticUnchecked/`
- `DenialOfService/`
- `WeakRandomness/`
- `UncheckedReturnValue/`
- `AccessControlMisconfig/`
- `SignatureReplay/`
- `DelegatecallStorageCollision/`
- `OracleManipulation/`
- `SelfdestructEdgeCases/`

Each folder is intentionally self-contained so you can study one class of bug at a time.

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
forge test --match-path TxOriginPhishing/TxOriginExamples.t.sol -vvv
forge test --match-path ArithmeticUnchecked/ArithmeticUncheckedExamples.t.sol -vvv
forge test --match-path DenialOfService/DenialOfServiceExamples.t.sol -vvv
forge test --match-path WeakRandomness/WeakRandomnessExamples.t.sol -vvv
forge test --match-path UncheckedReturnValue/UncheckedReturnValueExamples.t.sol -vvv
forge test --match-path AccessControlMisconfig/AccessControlExamples.t.sol -vvv
forge test --match-path SignatureReplay/SignatureReplayExamples.t.sol -vvv
forge test --match-path DelegatecallStorageCollision/DelegatecallStorageCollisionExamples.t.sol -vvv
forge test --match-path OracleManipulation/OracleManipulationExamples.t.sol -vvv
forge test --match-path SelfdestructEdgeCases/SelfdestructEdgeCasesExamples.t.sol -vvv
```

### 4. Run starter exercise tests only

```sh
forge test --match-path "**/ExercisesStarter.t.sol" -vvv
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

## Suggested Workflow

1. Read the issue `README.md`.
2. Run the matching test file.
3. Read the vulnerable contract, then the exploit contract, then the fixed contract.
4. Open `Exercises.sol` and implement your exploit/fix directly in Solidity.
5. Re-run tests after you implement your own exploit or fix.

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
