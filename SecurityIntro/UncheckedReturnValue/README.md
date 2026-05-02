# Unchecked Return Values

## What It Is

Some external calls do not revert on failure. They return `false` instead. If your contract ignores that return value, it may continue as if the action succeeded.

This is especially important for ERC20 interactions, legacy tokens, and low-level calls.

## Why It Matters

Ignoring a failed transfer can let users receive goods, permissions, or state changes without actually paying.

## Safer Rule

Always check return values. For ERC20 transfers in production code, prefer safe wrappers such as OpenZeppelin's `SafeERC20`.
