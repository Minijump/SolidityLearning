# Delegatecall Storage Collision

## What Is `delegatecall`?

`delegatecall` is a low-level EVM instruction, similar to a normal `call`, but with one critical difference: **the called contract's code runs inside the caller's context**.

This means:
- `msg.sender` and `msg.value` stay the same as seen by the proxy.
- All **storage reads and writes affect the calling contract's storage**, not the implementation's.
- The implementation contract's own storage is never touched.

### Normal `call` vs `delegatecall`

| | `call` | `delegatecall` |
|---|---|---|
| Code executed | target contract | target contract |
| Storage used | target contract | **caller contract** |
| `msg.sender` | caller | original caller |
| `msg.value` | value sent | original value |

### Why Is It Used?

`delegatecall` is the foundation of the **upgradeable proxy pattern**:

1. You deploy a **proxy** contract that holds all state (balances, owners, etc.) and never changes address.
2. You deploy a separate **implementation** (logic) contract that holds the actual code.
3. Every call to the proxy is forwarded via `delegatecall` to the implementation.
4. To upgrade, you just point the proxy at a new implementation — no state migration needed.

This lets you fix bugs or add features in a deployed contract while keeping the same address and state.

### Concrete Example

```
User  ──call──►  Proxy (holds state)
                    │
                    └─ delegatecall ──►  Implementation (holds code)
                                              │
                                        writes go back to
                                        Proxy's storage
```

When `Implementation.setOwner(newOwner)` runs via `delegatecall`, it writes to **slot 0 of the proxy**, not of `Implementation`.

## What It Is (The Vulnerability)

When `delegatecall` executes library logic in proxy storage, mismatched storage layouts can overwrite critical proxy slots.

If implementation pointers or admin slots overlap with logic variables, attacker-controlled calls can redirect execution.

## Why It Matters

A collision can let attackers replace implementation logic and drain funds.

## Safer Rule

Use unstructured storage slots for proxy metadata and strict upgrade access control.
