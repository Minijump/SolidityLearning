# Selfdestruct Edge Cases

## What It Is

Any contract can receive ETH via `selfdestruct`, even if it has no payable function. Designs that assume balance only changes through controlled functions can break.

## Why It Matters

Forced ETH can break invariants and trigger denial of service or accounting errors.

## Safer Rule

Never rely on `address(this).balance` alone as your trusted accounting source.

## IMPORTANT NOTE

selfdestruct is deprecated, this is a folder for 'legacy example'
