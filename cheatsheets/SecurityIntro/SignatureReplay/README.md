# Signature Replay

## What It Is

A replay vulnerability appears when a signed authorization can be reused multiple times.

If a contract verifies a signature but does not consume a nonce or unique message identifier, one signature can authorize repeated claims.

## Why It Matters

Attackers can replay old signed messages to withdraw funds repeatedly.

## Safer Rule

Bind signatures to unique, one-time values (nonces) and enforce single-use of each signed intent.
