# Inspecting Transactions

Learn how to view and analyze transaction details, gas usage, and execution results.

## What is a Transaction?

A transaction is a request to the blockchain to execute code or transfer value. It contains:
- **From** - Sender's address
- **To** - Recipient address (or empty for contract creation)
- **Value** - Amount of ETH being sent
- **Data** - Encoded function call or contract creation code
- **Gas** - Maximum amount of computation allowed
- **Gas Price** - Price per unit of gas

## Inspecting Transactions on Etherscan

### Step 1: Get Your Transaction Hash

After sending a transaction, you'll get a **transaction hash** (TX hash):
```
0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

### Step 2: Go to Etherscan

1. Open [etherscan.io](https://etherscan.io) (or [sepolia.etherscan.io](https://sepolia.etherscan.io) for testnet)
2. Paste your TX hash in the search box
3. Press Enter

### Step 3: Read the Transaction Details

**Key Information You'll See:**

| Field | What It Means |
|-------|---------------|
| **Status** | `Success` (✓) or `Failed` (✗) |
| **From** | Sender's wallet address |
| **To** | Smart contract being called |
| **Value** | ETH sent with this transaction |
| **Gas Used** | Actual computation used (in gwei) |
| **Gas Price** | Price per unit of computation |
| **Nonce** | Transaction number from sender's account |
| **Block** | Which block contains this transaction |

## Using Foundry to Inspect Transactions

### Basic: Get Transaction Details

If you're running a local blockchain with Anvil:

```bash
# Start a local blockchain
anvil

# In another terminal, deploy a contract and get the TX hash
# Then inspect it:
cast tx 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

### Get Specific Transaction Data

```bash
# Get sender address
cast tx 0x<tx_hash> --input from

# Get recipient address
cast tx 0x<tx_hash> --input to

# Get the value sent (in wei)
cast tx 0x<tx_hash> --input value

# Get the input data (encoded function call)
cast tx 0x<tx_hash> --input input

# Get gas used
cast tx 0x<tx_hash> --input gasUsed
```

### View Transaction Receipt

```bash
cast receipt 0x<tx_hash>
```

This shows:
- Transaction status (success/failure)
- Gas used vs gas limit
- Logs/events emitted
- Block number

## Understanding Gas

### What is Gas?

Gas measures how much computation a transaction uses. More complex operations use more gas.

### Understanding Gas Usage

On Etherscan, you'll see:

- **Gas Used** - Actual gas consumed (e.g., `21,000 gwei`)
- **Gas Limit** - Maximum you allowed (e.g., `30,000 gwei`)
- **Gas Price** - Price per unit (e.g., `50 gwei`)

**Formula:**
```
Transaction Cost = Gas Used × Gas Price
```

### Common Gas Amounts

| Operation | Gas Cost |
|-----------|----------|
| Send ETH to wallet | 21,000 |
| Transfer ERC20 token | ~65,000 |
| Swap on DEX | ~100,000+ |
| Deploy simple contract | ~200,000+ |

### See Detailed Gas Breakdown

In Etherscan, click on the **"State Changes"** tab to see exactly what the transaction did and how much gas each step used.

## Debugging Failed Transactions

### Step 1: Check the Status

On Etherscan, look at the **Status** field. If it shows `Failed`, continue.

### Step 2: Read the Error Message

Look for the **Revert Reason** or **Error** section. This tells you why it failed:

```
Error: execution reverted: Insufficient balance
```

### Step 3: Common Failure Reasons

| Error | Cause | Solution |
|-------|-------|----------|
| `execution reverted` | Contract logic rejected the transaction | Review contract code, check conditions |
| `out of gas` | Didn't provide enough gas | Increase gas limit when resubmitting |
| `invalid opcode` | Contract has a bug | Report to contract developer |
| `call failed` | Contract called another contract that failed | Check nested transaction failures |

### Step 4: Check Prerequisites

Common reasons transactions fail:

- **Not enough ETH** - You don't have enough for gas
- **Not approved** - You didn't approve the contract to spend your tokens
- **Wrong parameters** - You passed invalid data to the function
- **Condition not met** - The `require()` statement in the contract failed

### Debugging Locally

If you're developing with Foundry:

```bash
# Run a test with detailed output
forge test -vvv

# See the revert reason
forge test -vvv --match-test yourTestName
```

## Viewing Transaction Data

### Raw Input Data

In Etherscan, the **Input Data** section shows the encoded function call:

```
0x a9059cbb
   000000000000000000000000742d35cc6634C0532925a3b844Bc9e7595f6bEb
   0000000000000000000000000000000000000000000000000de0b6b3a7640000
```

This is the encoded contract function call. Etherscan will decode it for you in the **"Decode Input Data"** section.

### Understanding Encoded Data

- First 4 bytes = Function selector (identifies which function)
- Remaining bytes = Function parameters

Etherscan automatically shows you the decoded version - much easier!

## Step-by-Step Example

Let's say you deployed an ERC20 token and want to check a transfer:

1. **Get the TX hash** from your wallet or terminal
2. **Go to Etherscan** and paste the TX hash
3. **Check Status** - Make sure it says "Success"
4. **View Details:**
   - Click "To" to see which token contract was called
   - Look at "Input Data" section and click "Decode" to see the function called
   - See how many tokens were transferred
5. **Check Events** - See the "Logs" tab to confirm the `Transfer` event was emitted
6. **Verify Gas** - Check if gas used was reasonable (ERC20 transfers use ~60,000 gas)

## Tips

- **Bookmark Etherscan** - You'll use it constantly
- **Learn the tabs** - Overview, Transactions, Token Transfers, Logs, etc.
- **Decode everything** - Etherscan auto-decodes data, so use it
- **Compare to similar TXs** - If confused, look at other transactions doing the same thing
- **Use block explorers for testnets** - Sepolia, Mumbai, Goerli, etc. have their own explorers
