# Inspecting Blockchain State

Learn how to query account balances, contract state, and historical blockchain data.

## What is Blockchain State?

**State** = The current condition of the blockchain:
- Account balances
- Contract storage
- Nonce (transaction count)
- Smart contract code

The blockchain stores **all state** and you can query it anytime.

## Querying Account Balance

### Check Your Balance

**Etherscan Method:**
1. Go to [etherscan.io](https://etherscan.io)
2. Paste your address
3. See your ETH balance at the top

**Foundry CLI:**
```bash
# Check balance of an address
cast balance 0x1234567890abcdef1234567890abcdef12345678

# Check your own balance (if you have a local account)
cast balance --account your_account_name

# Check balance on specific chain
cast balance 0x1234567890abcdef1234567890abcdef12345678 --rpc-url https://sepolia.infura.io/v3/<YOUR_KEY>
```

### Understand Balance Output

```bash
$ cast balance 0x1234567890abcdef1234567890abcdef12345678
1250000000000000000
```

This is in **wei** (smallest unit).

**Convert to ETH:**
```bash
# Using cast
cast --from-wei 1250000000000000000

# Manual: divide by 10^18
# 1250000000000000000 / 1000000000000000000 = 1.25 ETH
```

### Balance at Specific Block

```bash
# Current balance
cast balance 0x<address>

# Balance at block 17000000
cast balance 0x<address> --block 17000000
```

This is useful for finding historical state.

## Querying Contract State

### Call Read-Only Functions

Contract functions marked `view` or `pure` don't change state and are free to call.

**Using Etherscan:**
1. Go to contract page
2. Click **"Read Contract"** tab
3. Interact with functions (free, no transaction cost)

**Using Foundry:**
```bash
# Call a function
cast call 0x<contract_address> "<function_signature>"

# Example: Get token name
cast call 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 "name()"

# Example: Get balance of specific address
cast call 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 "balanceOf(address)" 0x1234567890abcdef1234567890abcdef12345678
```

### Understanding Function Signatures

When using `cast call`, you need the **function signature**:

```solidity
// Solidity
function balanceOf(address account) public view returns (uint256)

// Function signature for cast call
"balanceOf(address)"

// With an argument
cast call <contract> "balanceOf(address)" <address_argument>
```

**More Examples:**

```solidity
function approve(address spender, uint256 amount) public returns (bool)
// Signature: "approve(address,uint256)"
// With arguments: "0xSpender" "1000000000000000000"

function transfer(address to, uint256 amount) public returns (bool)
// Signature: "transfer(address,uint256)"
```

## Checking Token Balances

### ERC20 Tokens (Fungible)

```bash
# Get token balance
cast call 0x<token_address> "balanceOf(address)" 0x<wallet_address>

# Example: Check USDC balance
cast call 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
  "balanceOf(address)" \
  0x1234567890abcdef1234567890abcdef12345678

# Get token decimals (to format output)
cast call 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 "decimals()"

# Result: 6 (USDC has 6 decimals)
# So if balance is 1000000, you have 1 USDC
```

### ERC721 Tokens (NFTs)

```bash
# Check if address owns token ID 1
cast call 0x<nft_contract> "ownerOf(uint256)" 1

# Get balance (number of NFTs owned)
cast call 0x<nft_contract> "balanceOf(address)" 0x<wallet_address>
```

## Reading Raw Storage

### What is Storage?

State variables are stored in **storage slots** - permanent storage on-chain.

### View Storage Directly

```bash
# View storage slot 0
cast storage 0x<contract_address> 0

# View storage slot 1
cast storage 0x<contract_address> 1
```

**Output is in hex:**
```
0x000000000000000000000000000000000000000000000000de0b6b3a7640000
```

### Decode Hex

```bash
# Convert hex to decimal
cast --to-dec 0x000000000000000000000000000000000000000000000000de0b6b3a7640000

# Result: 1000000000000000000 (1 token in wei)
```

### Understanding Storage Layout

Solidity stores state variables sequentially:

```solidity
contract Example {
    uint256 count = 5;           // Slot 0
    address owner = msg.sender;  // Slot 1
    bool paused = false;         // Slot 2
}
```

Each slot is 32 bytes. Multiple small types can share a slot.

### View Storage on Etherscan

1. Go to contract
2. Click **"Contract"** tab
3. Look for **"Storage at"** section
4. Etherscan lets you query specific slots

## Checking Nonce

**Nonce** = How many transactions an address has sent.

```bash
# Get nonce for an address
cast nonce 0x<address>

# Example output: 42
# This address has sent 42 transactions
```

**Why does this matter?**
- Used to prevent replay attacks
- Must increment for each transaction
- If you send transaction #43 with nonce 41, it will revert

## Historical State Queries

### State at Specific Block

```bash
# Get balance at block 17000000
cast balance 0x<address> --block 17000000

# Call function at specific block
cast call 0x<contract> "balanceOf(address)" 0x<address> --block 17000000
```

### Time Traveling

Find what happened at a specific time:

```bash
# Get block around a specific timestamp
# If block time is ~12 seconds, go back (current - timestamp) / 12 blocks

# Example: What was the balance at Feb 15, 2024?
# Look up block number for that date on Etherscan
# Then query: cast balance 0x<address> --block 19212345
```

## Account Information

### Get All Account Data

```bash
# Full account info (Foundry may not show all, but API does)
cast account 0x<address>

# Or use web request to Infura/Alchemy
curl -X POST https://sepolia.infura.io/v3/<YOUR_KEY> \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc":"2.0",
    "method":"eth_getBalance",
    "params":["0x<address>", "latest"],
    "id":1
  }'
```

## Advanced: RPC Methods

If you want to query in a script or program:

```bash
# Send raw JSON-RPC call
cast rpc eth_getBalance 0x<address> latest

# Get account code
cast rpc eth_getCode 0x<address> latest

# Get storage
cast rpc eth_getStorageAt 0x<address> 0 latest
```

These use JSON-RPC, the low-level protocol Ethereum uses.

## Practical Workflows

### "Did my transaction succeed?"

```bash
# 1. Get receipt
cast receipt 0x<tx_hash>

# 2. Check status (0 = failed, 1 = success)
cast receipt 0x<tx_hash> | grep -i status

# 3. If failed, see why
cast receipt 0x<tx_hash> | grep -i "revert\|error"
```

### "How much is this NFT worth?"

```bash
# 1. Get owner
cast call 0x<nft_contract> "ownerOf(uint256)" 1

# 2. Get metadata
cast call 0x<nft_contract> "tokenURI(uint256)" 1

# 3. Get price from floor (requires calling a DEX or oracle)
```

### "What happened to my tokens?"

```bash
# 1. Check current balance
cast call 0x<token> "balanceOf(address)" 0x<wallet>

# 2. Check at earlier block
cast call 0x<token> "balanceOf(address)" 0x<wallet> --block 17000000

# 3. Look at token transfer history on Etherscan
# Go to token contract, click "Token Transfers", filter by your address
```

## Tips

- **Always specify RPC** - Local vs testnet vs mainnet matters
- **Use Etherscan first** - For quick lookups, it's faster than CLI
- **Block numbers matter** - Same address can have different balance at different blocks
- **Free to read** - Querying state costs nothing (no transaction)
- **Function signature is key** - Incorrect signature = error
- **Check decimals** - Token balances need to be divided by 10^decimals
