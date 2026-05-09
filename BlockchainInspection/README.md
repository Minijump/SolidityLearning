# Blockchain Inspection Guide

A beginner-friendly guide to inspecting transactions, smart contracts, opcodes, blocks, and blockchain state.

## Why Learn This?

Understanding how to inspect blockchain data helps you:
- Debug smart contracts during development
- Verify contract behavior on-chain
- Understand how gas is used
- Learn how the EVM works
- Validate transactions before submitting them

## What You'll Learn

This folder contains focused guides on:

| Topic | What You'll Learn |
|-------|-------------------|
| **[Inspecting Transactions](./inspecting-transactions.md)** | How to view transaction details, gas usage, input data, and execution results |
| **[Inspecting Smart Contracts](./inspecting-smart-contracts.md)** | How to view contract code, state variables, storage layout, and check balances |
| **[Inspecting Opcodes](./inspecting-opcodes.md)** | Understanding low-level EVM bytecode and how to read it |
| **[Inspecting Blocks](./inspecting-blocks.md)** | How to examine block properties, timestamps, miners, and transactions |
| **[Inspecting Blockchain State](./inspecting-blockchain-state.md)** | How to query account balances, contract state, and historical data |

## Tools You'll Use

- **Foundry** (`forge`) - Local development and inspection
- **Etherscan** - Public blockchain explorer (Ethereum, Sepolia, etc.)
- **Cast** - Foundry CLI tool for querying blockchain data
- **Anvil** - Local blockchain for testing

## Quick Start

1. Start with **[Inspecting Transactions](./inspecting-transactions.md)** to understand the basics
2. Move to **[Inspecting Smart Contracts](./inspecting-smart-contracts.md)** to see how contracts work
3. Explore **[Inspecting Opcodes](./inspecting-opcodes.md)** to understand the EVM
4. Learn **[Inspecting Blocks](./inspecting-blocks.md)** for blockchain structure
5. Master **[Inspecting Blockchain State](./inspecting-blockchain-state.md)** for data queries

## Common Workflows

### I deployed a contract, now what?
→ See [Inspecting Smart Contracts](./inspecting-smart-contracts.md#after-deployment)

### My transaction failed, why?
→ See [Inspecting Transactions](./inspecting-transactions.md#debugging-failed-transactions)

### I want to understand gas usage
→ See [Inspecting Transactions](./inspecting-transactions.md#understanding-gas)

### I want to see contract storage
→ See [Inspecting Smart Contracts](./inspecting-smart-contracts.md#viewing-contract-storage)

### I want to learn how contracts execute
→ See [Inspecting Opcodes](./inspecting-opcodes.md)
