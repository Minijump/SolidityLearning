# Denial Of Service With Unexpected Revert

## What It Is

A common denial-of-service bug appears when a contract tries to push funds to many users in one transaction. If one recipient reverts, the whole loop can revert and nobody gets paid.

## Why It Matters

One malicious participant can block payouts or refunds for every honest user.

## Safer Rule

Prefer pull payments over push payments. Let each user withdraw their own funds instead of sending to everyone inside one loop.
