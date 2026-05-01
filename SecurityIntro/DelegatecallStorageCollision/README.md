# Delegatecall Storage Collision

## What It Is

When `delegatecall` executes library logic in proxy storage, mismatched storage layouts can overwrite critical proxy slots.

If implementation pointers or admin slots overlap with logic variables, attacker-controlled calls can redirect execution.

## Why It Matters

A collision can let attackers replace implementation logic and drain funds.

## Example Set

- `DelegatecallStorageCollisionExamples.sol`: vulnerable proxy, malicious implementation, and fixed proxy
- `DelegatecallStorageCollisionExamples.t.sol`: tests showing implementation hijack and the fix

## Safer Rule

Use unstructured storage slots for proxy metadata and strict upgrade access control.
