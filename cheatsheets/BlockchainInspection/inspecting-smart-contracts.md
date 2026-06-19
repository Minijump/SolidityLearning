# Inspecting Smart Contracts

Learn how to view contract code, check storage state, and verify deployment.

## What is a Smart Contract?

A smart contract is code deployed on the blockchain at a specific address. You can:
- View its source code
- Check its balance
- Read its state variables
- See all transactions interacting with it
- Call its functions

## Viewing Contract Code on Etherscan

### Step 1: Find the Contract Address

You need the contract's address (e.g., from deployment or a website):
```
0x1234567890abcdef1234567890abcdef12345678
```

### Step 2: Go to Etherscan

1. Open [etherscan.io](https://etherscan.io)
2. Paste the contract address in the search box
3. Press Enter

### Step 3: View the Contract Page

You'll see:
- **Balance** - How much ETH the contract holds
- **Token Tracker** - If it's a token (ERC20, ERC721, etc.)
- **Transactions** - All interactions with this contract
- **Comments** - Annotations from other users (helpful!)

### Step 4: Read the Source Code

Click the **"Contract"** tab, then:

- **Code** section - View the Solidity source code (if verified)
- **Read Contract** - Call functions that don't change state
- **Write Contract** - Call functions that change state (requires wallet)

## Verifying a Contract

Contract source code is only visible if someone has **verified** it on Etherscan.

### Why Verify?

- Users can see what the contract actually does
- Prevents scams (rugpulls, honeypots)
- Allows people to call functions directly on Etherscan

### How to Verify Your Contract

After deploying, go to Etherscan and:

1. Find your contract address
2. Click **"Contract"** tab
3. Click **"Verify and Publish"**
4. Fill in the form:
   - **Compiler Version** - Which version did you use? (e.g., `0.8.19`)
   - **License Type** - Select appropriate license
   - **Contract Code** - Copy-paste your Solidity code
5. Complete CAPTCHA
6. Submit

**Easy way using Foundry:**
```bash
forge verify-contract <address> <contract_name> --etherscan-api-key <YOUR_KEY> --chain sepolia
```

To get an Etherscan API key:
1. Go to [etherscan.io](https://etherscan.io)
2. Sign up or login
3. Go to API Keys
4. Create a new key

## Reading Contract State

### Using Etherscan (No Wallet Needed)

1. Go to contract page
2. Click **"Read Contract"** tab
3. You'll see all "view" and "pure" functions (read-only)
4. Click a function to see its output
5. Example: For an ERC20 token:
   - `balanceOf(address)` - See wallet balance
   - `totalSupply()` - Total tokens in existence
   - `name()` - Token name

### Using Foundry CLI

```bash
# Call a function on mainnet
cast call 0x<contract_address> "<function_signature>"

# Example: Get ERC20 token name
cast call 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 "name()"

# Example: Get balance of an address
cast call 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 "balanceOf(address)" 0x1234567890abcdef1234567890abcdef12345678

# Specify the chain
cast call 0x<address> "functionName()" --rpc-url https://sepolia.infura.io/v3/<YOUR_KEY>
```

## Viewing Contract Storage

### Why Check Storage?

State variables are stored in contract storage. Understanding storage helps you:
- Debug issues
- Understand how data is organized
- Optimize gas usage

### View Raw Storage Slots (Etherscan)

1. Go to contract page
2. Click **"Contract"** tab
3. Look for **"Storage at"** section
4. You can query specific storage slots

Example:
```
Storage Slot 0: 0x000000000000000000000000000000000000000000000000de0b6b3a7640000
```

### View Formatted Storage (Foundry)

```bash
# Get raw storage at slot 0
cast storage 0x<contract_address> 0

# Get ERC20 total supply (usually at slot 0)
cast storage 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 0

# Convert from hex to decimal
cast --to-dec 0x000000000000000000000000000000000000000000000000de0b6b3a7640000
```

### Understanding Storage Slots

Variables are stored sequentially:

```solidity
contract Example {
    uint256 count = 5;           // Slot 0
    address owner = msg.sender;  // Slot 1
    bool paused = false;         // Slot 2
}
```

Each slot is 32 bytes (256 bits). Multiple small types can fit in one slot.

## After Deployment

### Verify Everything Works

```bash
# 1. Check contract exists
cast code 0x<your_contract_address>

# 2. Call a view function to test
cast call 0x<your_contract_address> "yourFunction()"

# 3. Check ETH balance of contract (if applicable)
cast balance 0x<your_contract_address>

# 4. Get the deployment block
cast block-number
```

### Common Checks

- ✓ Contract code is not empty (`cast code` returns data)
- ✓ Constructor ran correctly (check events/logs)
- ✓ State variables initialized (check storage)
- ✓ Functions are callable (test calling a view function)

## Contract Interactions

### Check All Transactions

On the contract page in Etherscan:
- **Transactions** tab shows all interactions
- **Token Transfers** tab shows all token movements
- **Internal Transactions** tab shows contract-to-contract calls

### Understanding Transaction Traces

For complex transactions with multiple contract calls:

1. Go to Etherscan transaction page
2. Click **"State Changes"** or **"Logs"** tab
3. See which functions were called and in what order

## Contract Types

### EOA (Externally Owned Account)

Not a contract - just a wallet:
- No code
- Only has transactions and balance
- Can sign transactions

### Smart Contract

Has code deployed at the address:
- Has bytecode (visible via `cast code`)
- Can hold ETH and tokens
- Can be interacted with via transactions

**How to tell the difference:**
```bash
cast code 0x<address>

# Returns 0x if it's an EOA
# Returns bytecode (0x60806040...) if it's a contract
```

## Tips

- **Etherscan is your friend** - Use it to understand contracts before using them
- **Always verify source code** - Scam contracts won't be verified
- **Check transaction history** - See what functions are actually being called
- **Use "Read Contract"** - Call functions for free to test before writing code
- **Save verified contract ABIs** - You can download the ABI from Etherscan for your scripts
- **Check Solidity version** - Make sure contract was compiled with compatible version
