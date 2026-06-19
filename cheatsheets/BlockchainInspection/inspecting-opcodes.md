# Inspecting Opcodes

Learn about the low-level EVM bytecode that powers smart contracts.

## What are Opcodes?

An **opcode** is a single instruction for the Ethereum Virtual Machine (EVM).

Your Solidity code gets compiled down to opcodes:

```solidity
uint256 x = 5;
```

Becomes something like:

```
PUSH1 0x05    // Push the number 5 onto the stack
SSTORE        // Store it in memory
```

## Why Learn Opcodes?

- **Understand execution** - See exactly what your code does
- **Optimize gas** - Some opcodes cost more gas than others
- **Debug issues** - Understand where transactions fail
- **Learn the EVM** - How blockchain really works

## Viewing Contract Bytecode

### View on Etherscan

1. Go to any contract on Etherscan
2. Click the **"Contract"** tab
3. Scroll to **"Contract Bytecode"**
4. You'll see the raw bytes:

```
60806040523480156100...
```

### Decode Bytecode Using Foundry

```bash
# Get the bytecode of a deployed contract
cast code 0x<contract_address>

# Get the runtime bytecode (code that stays on chain)
cast code 0x<contract_address> --rpc-url <rpc_url>
```

### Disassemble to Readable Opcodes

Use online disassemblers:
- [evm.codes](https://evm.codes) - Interactive opcode reference
- [ethervm.io](https://ethervm.io) - Paste bytecode and see opcodes

**To use:**
1. Copy bytecode from `cast code <address>` or Etherscan
2. Paste into disassembler
3. See the opcode instructions

## Common Opcodes Explained

### Stack Operations

| Opcode | Name | Effect | Gas |
|--------|------|--------|-----|
| `PUSH1` | Push 1 byte | Puts a value on the stack | 3 |
| `POP` | Pop | Removes top value from stack | 2 |
| `DUP1` | Duplicate 1st | Copies top stack value | 3 |
| `SWAP1` | Swap positions | Swaps top two stack values | 3 |

**Example:**
```
PUSH1 0x05     // Stack: [5]
DUP1           // Stack: [5, 5]
ADD            // Stack: [10]
```

### Arithmetic

| Opcode | Operation | Gas |
|--------|-----------|-----|
| `ADD` | Addition | 3 |
| `SUB` | Subtraction | 3 |
| `MUL` | Multiplication | 5 |
| `DIV` | Division | 5 |
| `SDIV` | Signed division | 5 |
| `MOD` | Modulo | 5 |

### Memory & Storage

| Opcode | Function | Gas | Notes |
|--------|----------|-----|-------|
| `MSTORE` | Store in memory | 3 | Fast, temporary |
| `MLOAD` | Load from memory | 3 | Read temporary storage |
| `SSTORE` | Store in contract storage | 20,000 | Permanent, expensive |
| `SLOAD` | Load from storage | 2,100 | Read permanent storage |

### Comparison & Logic

| Opcode | Function | Gas |
|--------|----------|-----|
| `EQ` | Equals | 3 |
| `LT` | Less than | 3 |
| `GT` | Greater than | 3 |
| `AND` | Bitwise AND | 3 |
| `OR` | Bitwise OR | 3 |
| `NOT` | Bitwise NOT | 3 |

### Control Flow

| Opcode | Function | Gas | Notes |
|--------|----------|-----|-------|
| `JUMP` | Go to location | 8 | Unconditional jump |
| `JUMPI` | Jump if condition | 10 | Conditional jump |
| `CALL` | Call another contract | 700+ | Expensive! |
| `REVERT` | Undo transaction | 0 | Used in `require()` |
| `RETURN` | Return from function | 0 | End execution |

## Reading Bytecode Example

Here's a simple Solidity function:

```solidity
function add(uint256 a, uint256 b) public pure returns (uint256) {
    return a + b;
}
```

Compiled to opcodes:

```
60       PUSH1           // Prepare for first value
01       01              // The number 1 (this might vary)
60       PUSH1           
01       01
MLOAD    
01
```

**Don't worry if this looks confusing!** The key point is:
- Each instruction does one thing
- They operate on a **stack** (like a stack of plates)
- Complex operations = many opcodes = more gas

## Understanding Gas and Opcodes

Each opcode costs different amounts of gas:

```solidity
x = y + z;    // ADD opcode = 3 gas
x = y * z;    // MUL opcode = 5 gas
storage_var = x;  // SSTORE = 20,000 gas (!!!expensive)
```

Storage operations are expensive because they're permanent.

## Debugging Failed Transactions

Failed transactions often show opcodes related to failure:

```
REVERT opcode encountered
```

This usually means a `require()` statement failed:

```solidity
require(balance >= amount, "Insufficient balance");
// Compiles to: test condition, JUMPI, REVERT
```

## Optimizing Gas with Opcodes

Smart developers reduce gas by understanding opcodes:

```solidity
// EXPENSIVE: Uses memory
uint256 temp = x + y;
uint256 result = temp * z;

// CHEAPER: Keeps everything on stack, fewer operations
uint256 result = (x + y) * z;
```

## Tools to Explore Opcodes

### 1. **evm.codes** (Recommended for Learning)

Visit [evm.codes](https://evm.codes):
- Hover over any opcode to see gas cost
- See which opcodes are most expensive
- Interactive and visual

### 2. **Foundry's `forge inspect`**

```bash
# See the bytecode of a contract
forge inspect <contract_name> bytecode

# See the assembly (low-level representation)
forge inspect <contract_name> asm
```

### 3. **Online Decompilers**

Paste bytecode into:
- [Dedaub](https://dedaub.com) - Shows function signatures
- [Reverse Engineering Service](https://www.ethervm.io) - Shows all opcodes

## Key Takeaways

1. **Opcodes are the actual code** - Your Solidity gets compiled to them
2. **Different opcodes cost different gas** - Storage is expensive
3. **Stack-based execution** - The EVM uses a stack to compute
4. **Common bottleneck** - `SSTORE` (storing data) uses most gas
5. **Understanding helps optimization** - Write better, cheaper contracts

## Next Steps

- Visit [evm.codes](https://evm.codes) and explore opcodes
- Use `forge inspect` on your contracts
- Experiment with online disassemblers
- Start noticing which parts of your code use most gas
