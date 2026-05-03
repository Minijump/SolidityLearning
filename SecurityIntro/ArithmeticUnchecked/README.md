# Unchecked Arithmetic

## What It Is

Solidity `0.8+` checks arithmetic by default, but `unchecked { ... }` disables those protections.

If you use `unchecked` around balance accounting without a proof that underflow or overflow is impossible, you can recreate the classic arithmetic bugs from older Solidity versions.

## Why It Matters

A single underflow can turn a small balance into a huge number and break all later authorization or withdrawal logic.

## Safer Rule

Use checked arithmetic unless you have a very strong reason not to. If you do use `unchecked`, isolate it and prove the bounds first.
