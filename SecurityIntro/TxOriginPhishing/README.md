# tx.origin Phishing

## What It Is

Using `tx.origin` for authorization is unsafe. `tx.origin` is the original externally owned account that started the transaction, not the immediate caller.

If the owner is tricked into calling an attacker contract, that attacker contract can call the target wallet and still make `tx.origin` equal to the owner.

## Why It Matters

This bug turns social engineering into an access-control bypass.

## Safer Rule

Use `msg.sender` for authorization. Only use `tx.origin` if you fully understand the tradeoff and do not rely on it for permissions.
