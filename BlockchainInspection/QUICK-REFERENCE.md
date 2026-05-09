# Quick Reference

Fast lookup for common inspection commands and URLs.

## Etherscan Shortcuts

| Task | URL |
|------|-----|
| Search address/TX/contract | `etherscan.io` (paste in search) |
| Mainnet | `https://etherscan.io` |
| Sepolia testnet | `https://sepolia.etherscan.io` |
| Any address | `etherscan.io/address/0x123...` |
| Any transaction | `etherscan.io/tx/0xabc...` |
| Any block | `etherscan.io/block/18000000` |
| Token transfers | Click contract → "Token Transfers" tab |
| Verify contract | Click contract → "Verify & Publish" |

## Foundry Commands

### Balance & Account Info

```bash
# Check ETH balance
cast balance 0x<address>

# Check balance at specific block
cast balance 0x<address> --block 17000000

# Get nonce (transaction count)
cast nonce 0x<address>

# Get code (is it a contract?)
cast code 0x<address>
```

### Transactions

```bash
# Get transaction details
cast tx 0x<tx_hash>

# Get transaction receipt (status, gas, logs)
cast receipt 0x<tx_hash>

# Get specific field from TX
cast tx 0x<tx_hash> --input from
cast tx 0x<tx_hash> --input to
cast tx 0x<tx_hash> --input value
cast tx 0x<tx_hash> --input data
```

### Smart Contracts

```bash
# Call a read-only function (free, returns data)
cast call 0x<contract> "functionName()" --rpc-url <rpc>

# Call function with arguments
cast call 0x<contract> "balanceOf(address)" 0x<address> --rpc-url <rpc>

# Get contract storage
cast storage 0x<contract> 0        # Slot 0
cast storage 0x<contract> 1        # Slot 1

# View bytecode
cast code 0x<contract> --rpc-url <rpc>
```

### Blocks

```bash
# Current block number
cast block-number

# Get block details
cast block latest
cast block 18000000

# Get specific block data
cast block latest --json | grep gasUsed
cast block latest --json | grep timestamp
```

### Conversions

```bash
# Wei to ETH
cast --from-wei 1000000000000000000

# ETH to Wei
cast --to-wei 1

# Hex to decimal
cast --to-dec 0xabcd1234

# Decimal to hex
cast --from-dec 12345
```

## Token Commands

### ERC20 (Fungible Tokens)

```bash
# Token name
cast call 0x<token> "name()"

# Token symbol
cast call 0x<token> "symbol()"

# Token decimals
cast call 0x<token> "decimals()"

# Your balance
cast call 0x<token> "balanceOf(address)" 0x<wallet>

# Total supply
cast call 0x<token> "totalSupply()"

# Check allowance (how much you approved)
cast call 0x<token> "allowance(address,address)" 0x<owner> 0x<spender>
```

### ERC721 (NFTs)

```bash
# NFT owner
cast call 0x<nft> "ownerOf(uint256)" 1

# How many NFTs you own
cast call 0x<nft> "balanceOf(address)" 0x<wallet>

# Get NFT metadata
cast call 0x<nft> "tokenURI(uint256)" 1
```

## RPC Calls (Direct Blockchain Queries)

```bash
# Get balance (alternative method)
cast rpc eth_getBalance 0x<address> latest

# Get code (check if contract exists)
cast rpc eth_getCode 0x<address> latest

# Get storage
cast rpc eth_getStorageAt 0x<address> 0 latest

# Get transaction count
cast rpc eth_getTransactionCount 0x<address> latest
```

## Common Etherscan Tabs

| Tab | Shows |
|-----|-------|
| Overview | Basic info, balance, transactions |
| Transactions | All transactions involving this address |
| Token Transfers | All ERC20 transfers |
| Analytics | Charts of activity over time |
| Internal Txs | Contract-to-contract calls |
| Logs (Events) | All smart contract events emitted |
| Comments | User annotations |

*For contracts:*
| Tab | Shows |
|-----|-------|
| Code | Source code (if verified) |
| Read Contract | Call view/pure functions (free) |
| Write Contract | Call state-changing functions (costs gas) |
| Logs | All events emitted by this contract |
| State Changes | Detailed storage changes from transactions |

## RPC Endpoints

```bash
# Mainnet
https://eth-mainnet.g.alchemy.com/v2/<YOUR_KEY>
https://mainnet.infura.io/v3/<YOUR_KEY>

# Sepolia testnet
https://sepolia.infura.io/v3/<YOUR_KEY>
https://sepolia.g.alchemy.com/v2/<YOUR_KEY>

# Local Anvil
http://localhost:8545
```

## Getting API Keys

**Infura:** [infura.io](https://infura.io) (free tier available)
**Alchemy:** [alchemy.com](https://alchemy.com) (free tier available)
**Etherscan:** [etherscan.io → API Keys](https://etherscan.io/apis)

## Function Signature Format

```bash
# No arguments
"name()"
"totalSupply()"

# One argument
"balanceOf(address)"
"ownerOf(uint256)"

# Multiple arguments
"approve(address,uint256)"
"transfer(address,uint256)"
"transferFrom(address,address,uint256)"

# With return type (just for reference, don't include in cast call)
"function balanceOf(address) public view returns (uint256)"
# → For cast call, use only: "balanceOf(address)"
```

## Debugging Checklist

| Problem | Check |
|---------|-------|
| Transaction failed | Etherscan → Status field → Revert reason |
| No code at address | `cast code 0x<address>` (returns 0x = not a contract) |
| Can't call function | Wrong function signature or address not a contract |
| Unexpected balance | Check at specific block: `cast balance 0x<address> --block 17000000` |
| High gas cost | Etherscan → State Changes tab → see what operations ran |
| Token transfer failed | Check if you approved: `cast call 0x<token> "allowance(address,address)" <you> <spender>` |

## Gas Prices (Current Averages)

| Operation | Gas Cost |
|-----------|----------|
| Send ETH | 21,000 |
| Transfer ERC20 | ~65,000 |
| Approve token | ~45,000 |
| Contract deployment | 50,000 - 500,000 |
| DEX swap | 100,000 - 200,000 |

*Actual costs vary based on network congestion and operation complexity*

## Symbols & Conventions

```
0x...       = Ethereum address or data
wei         = Smallest ETH unit (1 ETH = 10^18 wei)
gwei        = Gas price unit (1 gwei = 10^9 wei)
tx          = Transaction
RPC         = Remote Procedure Call (network query)
ABI         = Application Binary Interface (contract interface)
ERC-20      = Fungible token standard
ERC-721     = NFT standard
view        = Read-only function
pure        = No state access, pure calculation
payable     = Function that accepts ETH
```

## Next Steps After Learning

1. ✓ Understand transactions → Deploy and monitor your first contract
2. ✓ Understand contracts → Read a verified contract's source code
3. ✓ Understand opcodes → Use `forge inspect` on your contracts
4. ✓ Understand blocks → Query historical state at different blocks
5. ✓ Understand state → Write a script that queries and analyzes data

## Resources

- **[evm.codes](https://evm.codes)** - Interactive opcode reference
- **[Etherscan](https://etherscan.io)** - Official Ethereum explorer
- **[Solidity Docs](https://docs.soliditylang.org)** - Language reference
- **[Foundry Book](https://book.getfoundry.sh)** - Foundry documentation
- **[OpenZeppelin Contracts](https://docs.openzeppelin.com)** - Safe contract patterns
