# Access Control Misconfiguration

## What It Is

Access control bugs happen when privileged functions are callable by the wrong account or ownership can be captured unexpectedly.

A frequent pattern is using an external `initialize()` without restricting who can call it first.

## Why It Matters

If an attacker can become owner, every admin-only function becomes attacker-controlled.

## Example Set

- `AccessControlExamples.sol`: vulnerable initializable vault, exploit helper, and fixed constructor-based vault
- `AccessControlExamples.t.sol`: tests showing ownership capture and the fix

## Safer Rule

Use constructor-based ownership when possible. If you need initialization, gate it so only a trusted deployer/factory can initialize.
