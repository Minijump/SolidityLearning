# Inspecting Blocks

Learn about blockchain blocks and how to view block data.

## What is a Block?

A **block** is a container of transactions. Every block contains:

| Data | What It Is |
|------|-----------|
| **Block Number** | Sequential ID (e.g., block 18,000,000) |
| **Timestamp** | When it was created (Unix time) |
| **Miner** | Who created it (now Validator on Proof of Stake) |
| **Transactions** | List of transactions in the block |
| **Gas Used** | Total computation used by all transactions |
| **Gas Limit** | Maximum computation allowed |
| **Block Reward** | ETH given to miner/validator for creating it |
| **Difficulty** | Proof-of-work difficulty (historical) |
| **Parent Hash** | Hash of the previous block (links blocks together) |

## Viewing Block Data on Etherscan

### Find a Block

1. Go to [etherscan.io](https://etherscan.io)
2. In the search box, enter:
   - **Block number** - e.g., `18000000`
   - **Block hash** - e.g., `0xabcd...`
   - Or use `Latest Blocks` link on homepage

### Read Block Information

You'll see:

```
Block #18000000

Status: Finalized
Timestamp: Feb-23-2024 02:45:47 PM +UTC
Transactions: 147
Miner: 0x1234...
Block Reward: 2 ETH
Difficulty: 100 GH/s
Gas Used: 24,523,456 / 30,000,000 (81.7%)
```

### View All Transactions in a Block

1. Click **"Transactions"** tab
2. See all transactions in order
3. Click on any transaction to view details

### Understanding Block Structure

- **Block Height / Number** - How many blocks since Genesis
- **Timestamp** - Approximate (miners can manipulate ±15 seconds)
- **Difficulty** - How hard it was to find this block
- **Gas Used vs Limit** - See how "full" the block is

## Viewing Blocks with Foundry

### Get Latest Block Number

```bash
cast block-number
```

Output: `18123456`

### Get Block Details

```bash
# Get info about a specific block
cast block 18000000

# Get latest block
cast block latest
```

Output:
```
baseFeePerGas        24 gwei
difficulty           0
extraData            0xd883010d0a...
gasLimit             30000000
gasUsed              24523456
hash                 0xabcd1234...
miner                0x1234567890abcdef...
number               18000000
parentHash           0xdef4567890ab...
timestamp            1708607147
```

### Get Specific Block Data

```bash
# Get timestamp of a block
cast block 18000000 --json | grep -i timestamp

# Get gas used
cast block latest --json | grep gasUsed

# Get miner address
cast block latest --json | grep miner
```

## Block Time

### What is Block Time?

**Block time** = Average time between blocks.

**Bitcoin:** ~10 minutes per block
**Ethereum:** ~12-13 seconds per block (after Merge)

This changes based on difficulty/network conditions.

### Calculate Block Time

```bash
# Get current block
CURRENT=$(cast block-number)

# Get block from 1 hour ago (250 blocks ago)
PREVIOUS=$((CURRENT - 250))

# Get timestamps
TIME_CURRENT=$(cast block $CURRENT | grep timestamp | awk '{print $2}')
TIME_PREVIOUS=$(cast block $PREVIOUS | grep timestamp | awk '{print $2}')

# Calculate
DIFF=$((TIME_CURRENT - TIME_PREVIOUS))
AVERAGE=$((DIFF / 250))

echo "Average block time: $AVERAGE seconds"
```

## Understanding Gas Per Block

### Gas Limit

Each block has a **gas limit** - total computation allowed:
- **Current:** ~60,000,000 gas per block (soon 200 000 000)
- **Can increase/decrease** - Network votes
- **Determines throughput** - How many transactions fit

### Gas Used

Actual gas used by transactions in the block.

- **High usage** = Block was "full", network congested
- **Low usage** = Plenty of space, fast/cheap transactions

### Practical Meaning

If gas limit is 30M and block uses 29M:
- Network is congested
- Gas prices are high
- Transactions take longer
- You need to pay more to get included

If gas limit is 30M and block uses 5M:
- Network is quiet
- Gas prices are low
- Your transaction confirms quickly

## Block Finality

### What is Finality?

**Finality** = The guarantee that a block cannot be reversed.

**Ethereum after Merge:**
- Blocks are **tentative** for ~15 seconds
- After 2 checkpoints (~13 minutes) = **finalized** (permanent)

### Check Finality on Etherscan

Look for:
- 🟢 **Green checkmark** = Finalized, permanent
- 🟡 **Yellow** = Tentative, could be reorged
- 🔴 **Red X** = Failed block (rare)

## Account Balance at Specific Block

### Why Check Historical Balance?

You want to know "How much ETH did this address have at block 15,000,000?"

### Using Etherscan

1. Go to address page
2. Look for **"Balance at Block"** (may vary)
3. Enter the block number
4. See historical balance

### Using Foundry

```bash
# Get balance at latest block
cast balance 0x1234567890abcdef1234567890abcdef12345678

# Get balance at specific block
cast balance 0x1234567890abcdef1234567890abcdef12345678 --block 18000000
```

## Block Rewards

### What is a Block Reward?

**Block reward** = ETH given to whoever creates the block.

**Current (Ethereum 2023+):**
- 2 ETH per block (Proof of Stake)
- ~300 ETH/day created (decreases over time)

**Before (Proof of Work):**
- Started at 50 ETH per block (2015)
- Halved every 4 years
- Reached 0.5 ETH after multiple halvings

### Where Do Rewards Go?

```
Block Reward = Base Reward + Tips from Transactions
    
Example: 2 ETH + 0.5 ETH (from transaction tips) = 2.5 ETH total
```

The **miner/validator** keeps the rewards.

## Viewing Mined Blocks

### Who Creates Blocks?

**Proof of Stake (current):**
- Validators create blocks
- Selected randomly, weighted by stake
- Receive 2 ETH per block

**Proof of Work (historical):**
- Miners solved math puzzles
- First to solve got to create block
- Higher difficulty = harder puzzle

### See Block Creator

On Etherscan block page:

```
Mined by: Lido
...
```

Or with Foundry:

```bash
cast block 18000000 | grep miner
```

## Chain Reorganizations (Reorgs)

### What is a Reorg?

**Reorg** = Blockchain reorganizes blocks, undoing some transactions.

**Cause:**
- Validator offline, another validator takes over
- Network latency issues
- Very rare on Ethereum (< 1 per million blocks)

### Impact

If you sent a transaction in a reorged block:
- Transaction undoes
- You need to resend it
- **This is extremely rare**

### Check For Reorgs

Etherscan will show if a block was reorged - you'll see older blocks disappear and reappear.

## Uncle Blocks (Historical)

**Note:** Uncle blocks only existed before Ethereum merged to Proof of Stake (Sep 2022).

In Proof of Work, sometimes two miners find blocks at nearly the same time. One becomes the "uncle" (not included in main chain but acknowledged).

This is no longer relevant for current Ethereum.

## Tips

- **Block time is average** - Can be 3 seconds or 30 seconds
- **Monitor gas** - See if network is congested
- **Finality matters** - Wait for finality before considering transaction permanent
- **Latest block** - Usually ~12 seconds from now (updating)
- **Historical data** - All data is queryable at any block number
- **Watch the chain** - Use `cast block latest --follow` to monitor new blocks (some versions)
