# Oracle Manipulation

## What It Is

Protocols that rely on a manipulable spot price can be exploited by temporarily moving that price and borrowing or redeeming at unfair terms.

## Why It Matters

A manipulated oracle can produce under-collateralized loans and insolvency.

## Example Set

- `OracleManipulationExamples.sol`: vulnerable spot-price lending and a safer trusted-oracle variant
- `OracleManipulationExamples.t.sol`: tests showing borrow inflation and the fix

## Safer Rule

Avoid single-transaction spot prices from manipulable pools. Use robust feeds (TWAP, Chainlink, bounded updates, multi-source checks).
