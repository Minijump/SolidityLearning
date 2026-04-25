# Solidity Cheatsheet

## Table of Contents
1. [Basic Contract Structure](#basic-contract-structure)
2. [Data Types & Structures](#data-types--structures)
3. [Function Visibility](#function-visibility)
4. [Function Modifiers (State & Payment)](#function-modifiers-state--payment)
5. [Custom Modifiers](#custom-modifiers)
6. [Storage Keywords](#storage-keywords)
7. [Inheritance](#inheritance)
8. [Interfaces](#interfaces)
9. [Events](#events)
10. [Error Handling](#error-handling)
11. [ERC20 Tokens](#erc20-tokens)
12. [OpenZeppelin Contracts](#openzeppelin-contracts)
13. [Special Functions](#special-functions)
14. [Common Patterns](#common-patterns)

---

## Basic Contract Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MyContract {
    // State variables
    uint256 public myNumber;
    address public owner;
    
    // Constructor - runs once when deployed
    constructor() {
        owner = msg.sender;
    }
    
    // Functions
    function setNumber(uint256 _number) public {
        myNumber = _number;
    }
}
```

---

## Data Types & Structures

### Primitive Types
```solidity
// Unsigned integers
uint256 public myUint = 100;        // 0 to 2^256 - 1
uint8 public smallUint = 255;       // 0 to 255

// Signed integers
int256 public myInt = -50;          // -(2^255) to 2^255 - 1

// Boolean
bool public isActive = true;

// Address
address public userAddress = 0x123...;
address payable public recipient;   // Can receive ETH

// Bytes
bytes32 public fixedBytes;          // Fixed-size byte array
bytes public dynamicBytes;          // Dynamic byte array

// String
string public name = "Alice";
```

### Arrays
```solidity
// Fixed-size array
uint256[5] public fixedArray;

// Dynamic array
uint256[] public dynamicArray;
address[] public users;

// Array operations
function arrayExample() public {
    dynamicArray.push(10);                  // Add element
    dynamicArray.pop();                     // Remove last element
    uint256 len = dynamicArray.length;      // Get length
    dynamicArray[0] = 5;                    // Access/modify by index
    
    // Reset array
    dynamicArray = new uint256[](0);
}
```

### Mappings
```solidity
// Simple mapping
mapping(address => uint256) public balances;

// Named mapping parameters (better readability)
mapping(address user => uint256 balance) public userBalances;

// Nested mapping
mapping(address => mapping(address => uint256)) public allowances;

// Mapping with enum values
enum Status { Pending, Active, Inactive }
mapping(address => Status) public userStatus;

// Using mappings
function mappingExample() public {
    balances[msg.sender] = 100;             // Set value
    uint256 myBalance = balances[msg.sender]; // Get value (returns 0 if not set)
}
```

### Structs
```solidity
// Define struct
struct Person {
    string name;
    uint256 age;
    address wallet;
}

// Use struct
Person public alice;
Person[] public people;
mapping(address => Person) public addressToPerson;

function structExample() public {
    // Create struct - method 1
    Person memory newPerson = Person("Bob", 30, msg.sender);
    
    // Create struct - method 2
    Person memory anotherPerson = Person({
        name: "Charlie",
        age: 25,
        wallet: msg.sender
    });
    
    // Add to array
    people.push(newPerson);
    
    // Access struct fields
    string memory name = people[0].name;
}
```

### Enums
```solidity
// Define enum
enum State { 
    Pending,    // 0
    Active,     // 1
    Completed,  // 2
    Cancelled   // 3
}

State public currentState;

function enumExample() public {
    currentState = State.Active;                    // Set value
    
    if (currentState == State.Active) {             // Compare
        // Do something
    }
    
    // Convert to uint
    uint256 stateValue = uint256(currentState);     // Returns 1
}
```

---

## Function Visibility

Controls **who** can call a function:

```solidity
contract VisibilityExample {
    // PUBLIC - callable from anywhere (external + internal)
    // Most common for user-facing functions
    function publicFunc() public returns (uint256) {
        return 1;
    }
    
    // EXTERNAL - only callable from outside the contract
    // Slightly more gas efficient than public for external calls
    // Cannot be called internally (unless using this.func())
    function externalFunc() external returns (uint256) {
        return 2;
    }
    
    // INTERNAL - only callable from this contract or derived contracts
    // Default for internal helper functions
    function internalFunc() internal returns (uint256) {
        return 3;
    }
    
    // PRIVATE - only callable from this contract (not derived contracts)
    // Use for sensitive internal logic
    function privateFunc() private returns (uint256) {
        return 4;
    }
    
    function callExample() public {
        publicFunc();           // ✅ Works
        // externalFunc();      // ❌ Error - use this.externalFunc()
        internalFunc();         // ✅ Works
        privateFunc();          // ✅ Works
    }
}
```

**Quick Guide:**
- `public` - Default choice for user-facing functions
- `external` - For functions only called externally (saves gas)
- `internal` - For helper functions used across inheritance
- `private` - For sensitive logic that shouldn't be inherited

---

## Function Modifiers (State & Payment)

Controls **what** the function can do with blockchain state:

### View - Read-Only
```solidity
// VIEW - reads state but doesn't modify it
// No gas cost when called externally
uint256 public count = 0;

function getCount() public view returns (uint256) {
    return count;               // ✅ Can read state
    // count = 5;              // ❌ Cannot modify state
}

function getBalance(address user) public view returns (uint256) {
    return user.balance;        // ✅ Can read blockchain data
}
```

### Pure - No State Access
```solidity
// PURE - doesn't read or modify state
// Use for pure computations
function add(uint256 a, uint256 b) public pure returns (uint256) {
    return a + b;               // ✅ Pure calculation
    // return count;           // ❌ Cannot read state
}

function calculatePrice(uint256 amount) public pure returns (uint256) {
    return amount * 100;        // ✅ Pure math
}
```

### Payable - Accept ETH
```solidity
// PAYABLE - can receive ETH
function deposit() public payable {
    // msg.value contains the amount of ETH sent
    require(msg.value > 0, "Must send ETH");
}

// Non-payable function (default)
function regularFunction() public {
    // This function will revert if ETH is sent
}
```

**Quick Guide:**
- `view` - Reading data (free when called externally)
- `pure` - Mathematical calculations, no blockchain interaction
- `payable` - Function needs to receive ETH
- No modifier - Function modifies state but doesn't receive ETH

---

## Custom Modifiers

Modifiers add reusable checks or logic to functions:

```solidity
contract ModifierExample {
    address public owner;
    bool public paused = false;
    
    constructor() {
        owner = msg.sender;
    }
    
    // Basic access control modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;  // This is where the function body executes
    }
    
    // Conditional modifier
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    // Modifier with parameters
    modifier minAmount(uint256 _amount) {
        require(msg.value >= _amount, "Insufficient amount");
        _;
    }
    
    // Using modifiers
    function withdraw() public onlyOwner whenNotPaused {
        // Function body
    }
    
    // Multiple modifiers (executed left to right)
    function deposit() public payable minAmount(1 ether) whenNotPaused {
        // Function body
    }
    
    // Modifier with custom error (gas efficient)
    error NotAuthorized();
    
    // ⚠️ LESS EFFICIENT - Logic inlined into every function
    modifier onlyAuthorizedBad() {
        if (msg.sender != owner) {
            revert NotAuthorized();
        }
        _;
    }
    
    // ✅ MORE EFFICIENT - Extract logic to private function
    // This pattern reduces bytecode size and deployment costs
    function _checkAuthorized() private view {
        if (msg.sender != owner) {
            revert NotAuthorized();
        }
    }
    
    modifier onlyAuthorized() {
        _checkAuthorized();  // Call the function instead
        _;
    }
    
    // Benefits:
    // 1. Function code stored once, not inlined into every usage
    // 2. Can call _checkAuthorized() directly if needed
    // 3. Smaller contract size = lower deployment gas costs
}
```

---

## Storage Keywords

Controls **where** data is stored:

```solidity
contract StorageExample {
    uint256 public stateVariable;  // Stored in STORAGE (permanent)
    
    function storageKeywords(string calldata _name) public {
        // STORAGE - permanent blockchain storage
        // Most expensive, persists between function calls
        stateVariable = 100;
        
        // MEMORY - temporary, erased after function execution
        // Used for reference types (arrays, structs, strings)
        string memory tempString = "Hello";
        uint256[] memory tempArray = new uint256[](5);
        
        // CALLDATA - read-only, used for function parameters
        // Most gas efficient for external function parameters
        // Already contains _name from function parameter
        bytes memory nameBytes = bytes(_name);
    }
    
    function stringExample(string memory _str) public {
        // string parameter must be memory or calldata
    }
    
    function arrayExample() public view {
        uint256[] memory myArray = new uint256[](3);
        myArray[0] = 1;
        // myArray exists only during this function call
    }
}

// CONSTANT & IMMUTABLE - special storage keywords
contract ConstantExample {
    // CONSTANT - set at compile time, cannot change
    // Cheapest gas, directly embedded in bytecode
    uint256 public constant MAX_SUPPLY = 1000000;
    string public constant NAME = "MyToken";
    
    // IMMUTABLE - set once in constructor, then read-only
    // Cheaper than regular storage
    address public immutable owner;
    uint256 public immutable deploymentTime;
    
    constructor() {
        owner = msg.sender;
        deploymentTime = block.timestamp;
        // Cannot change these values after deployment
    }
}
```

**Quick Guide:**
- `storage` - Permanent state variables (automatically for state vars)
- `memory` - Temporary data in functions (arrays, structs, strings)
- `calldata` - Read-only function parameters (most gas efficient)
- `constant` - Fixed at compile time, never changes
- `immutable` - Set once in constructor, then fixed

---

## Inheritance

Solidity supports inheritance for code reuse:

```solidity
// Base contract
contract Animal {
    string public name;
    
    constructor(string memory _name) {
        name = _name;
    }
    
    function speak() public virtual returns (string memory) {
        return "Some sound";
    }
    
    function eat() public pure returns (string memory) {
        return "Eating...";
    }
}

// Single inheritance
contract Dog is Animal {
    constructor(string memory _name) Animal(_name) {}
    
    // Override parent function
    function speak() public pure override returns (string memory) {
        return "Woof!";
    }
}

// Multiple inheritance (left to right order matters)
contract Ownable {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

contract Pausable {
    bool public paused;
    
    function pause() public {
        paused = true;
    }
}

// Inheriting from multiple contracts
contract MyContract is Ownable, Pausable {
    // Has access to owner, pause(), and onlyOwner modifier
    
    function doSomething() public onlyOwner {
        // Function logic
    }
}

// Calling parent functions
contract Cat is Animal {
    constructor() Animal("Cat") {}
    
    function speak() public pure override returns (string memory) {
        return "Meow!";
    }
    
    function speakLikeParent() public pure returns (string memory) {
        return super.speak();  // Calls Animal.speak()
    }
}
```

**Inheritance Order:**
- When inheriting multiple contracts, order matters: `contract C is A, B`
- If both A and B have the same function, B's version is used (rightmost priority)
- Use `super` to call parent function
- Use `override` keyword when overriding parent functions

---

## Interfaces

Interfaces define a contract's external API without implementation:

```solidity
// Define an interface
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    
    // Events can be declared
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// Using an interface to interact with another contract
contract MyContract {
    IERC20 public token;
    
    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);  // Cast address to interface
    }
    
    function checkBalance() public view returns (uint256) {
        return token.balanceOf(msg.sender);
    }
    
    function transferTokens(address to, uint256 amount) public {
        require(token.transfer(to, amount), "Transfer failed");
    }
}

// Custom interface example
interface IMyDAO {
    function vote(uint256 proposalId, bool support) external;
    function createProposal(string memory description) external returns (uint256);
    function executeProposal(uint256 proposalId) external;
}

contract DAOUser {
    IMyDAO public dao;
    
    constructor(address daoAddress) {
        dao = IMyDAO(daoAddress);
    }
    
    function voteOnProposal(uint256 id) public {
        dao.vote(id, true);
    }
}
```

**Interface Rules:**
- Cannot have state variables
- Cannot have constructors
- All functions must be `external`
- Cannot inherit from contracts (only other interfaces)
- Used to interact with external contracts

---

## Events

Events log information on the blockchain for external consumption:

```solidity
contract EventExample {
    // Define events
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Deposit(address indexed user, uint256 amount, uint256 timestamp);
    event ProposalCreated(uint256 indexed proposalId, string description);
    
    // Indexed parameters (up to 3) allow filtering
    // Non-indexed parameters are cheaper but can't be filtered
    
    function transfer(address to, uint256 amount) public {
        // Function logic...
        
        // Emit event
        emit Transfer(msg.sender, to, amount);
    }
    
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }
}

// Events are useful for:
// - Frontend notifications
// - Transaction history
// - Cheaper than storing data in state
// - Can be filtered by indexed parameters
```

**Event Best Practices:**
- Use `indexed` for parameters you want to filter (max 3)
- Events cost gas but are much cheaper than storage
- Always emit events for important state changes
- Use descriptive event names (past tense: Transfer, Created, Updated)

---

## Error Handling

Solidity provides multiple ways to handle errors:

```solidity
contract ErrorHandling {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    // 1. REQUIRE - for input validation
    // Gas refunded if fails
    function requireExample(uint256 amount) public {
        require(amount > 0, "Amount must be positive");
        require(msg.sender == owner, "Only owner");
    }
    
    // 2. REVERT - manual revert with message
    function revertExample(uint256 amount) public {
        if (amount == 0) {
            revert("Amount cannot be zero");
        }
    }
    
    // 3. CUSTOM ERRORS - most gas efficient (Solidity 0.8.4+)
    error InsufficientBalance(uint256 requested, uint256 available);
    error Unauthorized(address caller);
    error AmountTooLow();
    
    function customErrorExample(uint256 amount) public {
        if (msg.sender != owner) {
            revert Unauthorized(msg.sender);
        }
        
        if (amount < 100) {
            revert AmountTooLow();
        }
        
        uint256 balance = 50;
        if (amount > balance) {
            revert InsufficientBalance(amount, balance);
        }
    }
    
    // 4. ASSERT - for internal errors and invariants
    // Should never fail in normal operation
    // No gas refund if fails
    function assertExample(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);  // Check for overflow (pre-0.8.0)
        return c;
    }
}
```

**Error Handling Quick Guide:**
- `require()` - Input validation, user errors (gas refund)
- `revert()` - Complex conditions, explicit revert
- Custom errors - Most gas efficient, can include parameters
- `assert()` - Internal errors, should never fail

**Modern Pattern (Recommended):**
```solidity
error NotOwner();
error InsufficientAmount(uint256 sent, uint256 required);

modifier onlyOwner() {
    if (msg.sender != owner) {
        revert NotOwner();
    }
    _;
}
```

---

## ERC20 Tokens

ERC20 is the standard for fungible tokens:

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Basic ERC20 implementation
contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}

// ERC20 with custom logic
contract CustomToken is ERC20 {
    address public owner;
    
    constructor() ERC20("CustomToken", "CTK") {
        owner = msg.sender;
        _mint(msg.sender, 1000000 * 10**decimals());  // 1 million tokens
    }
    
    // Mint new tokens (only owner)
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Only owner");
        _mint(to, amount);
    }
}

// Using ERC20 tokens in another contract
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract TokenUser {
    IERC20 public token;
    
    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }
    
    // Receive tokens (user must approve first)
    function receiveTokens(uint256 amount) public {
        // User must call token.approve(thisContract, amount) first
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }
    
    // Send tokens
    function sendTokens(address to, uint256 amount) public {
        require(token.transfer(to, amount), "Transfer failed");
    }
    
    // Check balance
    function checkBalance(address account) public view returns (uint256) {
        return token.balanceOf(account);
    }
}
```

**ERC20 Key Functions:**
- `balanceOf(address)` - Check token balance
- `transfer(address, uint256)` - Send tokens directly
- `approve(address, uint256)` - Allow spender to use your tokens
- `transferFrom(address, address, uint256)` - Transfer tokens on behalf of someone
- `allowance(address, address)` - Check approved amount

**ERC20 Flow:**
1. User approves contract: `token.approve(contractAddress, amount)`
2. Contract transfers tokens: `token.transferFrom(user, contract, amount)`

---

## OpenZeppelin Contracts

OpenZeppelin provides secure, audited contract implementations:

### Common OpenZeppelin Imports

```solidity
// ERC20 Token
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ERC20 with burn functionality
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// Access control
import "@openzeppelin/contracts/access/Ownable.sol";

// Reentrancy protection
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// ERC20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
```

### Ownable - Access Control
```solidity
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    // Ownable automatically creates:
    // - address public owner
    // - modifier onlyOwner()
    // - function transferOwnership(address)
    // - function renounceOwnership()
    
    constructor() Ownable(msg.sender) {
        // In newer versions, pass initial owner to constructor
    }
    
    function restrictedFunction() public onlyOwner {
        // Only owner can call this
    }
}
```

### ERC20Burnable - Burn Tokens
```solidity
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract BurnableToken is ERC20Burnable {
    constructor() ERC20("Burnable", "BURN") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
    
    // Inherits burn functions:
    // - burn(uint256 amount) - burn your own tokens
    // - burnFrom(address, uint256) - burn tokens you're approved for
}
```

### ReentrancyGuard - Prevent Reentrancy Attacks
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecureContract is ReentrancyGuard {
    mapping(address => uint256) public balances;
    
    // nonReentrant prevents reentrancy attacks
    function withdraw() public nonReentrant {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");
        
        balances[msg.sender] = 0;  // State change before external call
        
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}
```

### Multiple Inheritance with OpenZeppelin
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedToken is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Advanced", "ADV") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
    
    // Only owner can mint new tokens
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    
    // Anyone can burn their own tokens (from ERC20Burnable)
    // Only owner can call mint (from Ownable)
}
```

---

## Special Functions

### Receive and Fallback - Handle ETH Transfers

```solidity
contract SpecialFunctions {
    event Received(address sender, uint256 amount);
    event FallbackCalled(address sender, uint256 amount, bytes data);
    
    // RECEIVE - called when ETH is sent with empty calldata
    // Must be external payable
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    // FALLBACK - called when:
    // 1. Function signature doesn't match any function
    // 2. ETH sent with data but no receive() function
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }
}

// Decision tree for incoming calls:
// Send ETH to contract
//     ↓
// Is msg.data empty?
//     ├─ Yes → receive() exists? → receive()
//     │                           → fallback() (if payable)
//     └─ No  → function exists?  → call that function
//                                → fallback()
```

### Constructor - Initialize Contract
```solidity
contract ConstructorExample {
    address public owner;
    uint256 public creationTime;
    string public name;
    
    // Simple constructor
    constructor() {
        owner = msg.sender;
        creationTime = block.timestamp;
    }
    
    // Constructor with parameters
    constructor(string memory _name) {
        owner = msg.sender;
        name = _name;
    }
    
    // Payable constructor (can receive ETH on deployment)
    constructor() payable {
        require(msg.value >= 1 ether, "Need 1 ETH to deploy");
        owner = msg.sender;
    }
}
```

---

## Common Patterns

### Checks-Effects-Interactions (CEI) Pattern
Prevents reentrancy attacks:

```solidity
contract CEIPattern {
    mapping(address => uint256) public balances;
    
    function withdraw() public {
        // 1. CHECKS - validate conditions
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");
        
        // 2. EFFECTS - update state
        balances[msg.sender] = 0;
        
        // 3. INTERACTIONS - external calls
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}
```

### Pull Over Push Pattern
Let users withdraw instead of pushing payments:

```solidity
contract PullPattern {
    mapping(address => uint256) public pendingWithdrawals;
    
    // Bad: Push pattern (vulnerable to failing recipients)
    function badDistribute(address[] memory recipients) public {
        for (uint i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(1 ether);  // Can fail
        }
    }
    
    // Good: Pull pattern
    function goodDistribute(address[] memory recipients) public {
        for (uint i = 0; i < recipients.length; i++) {
            pendingWithdrawals[recipients[i]] += 1 ether;
        }
    }
    
    function withdraw() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
```

### Factory Pattern
Deploy contracts from a contract:

```solidity
contract Token {
    string public name;
    address public owner;
    
    constructor(string memory _name, address _owner) {
        name = _name;
        owner = _owner;
    }
}

contract TokenFactory {
    Token[] public deployedTokens;
    
    function createToken(string memory name) public {
        Token newToken = new Token(name, msg.sender);
        deployedTokens.push(newToken);
    }
    
    function getDeployedTokens() public view returns (Token[] memory) {
        return deployedTokens;
    }
}
```

### Using Libraries for Types
Attach library functions to types:

```solidity
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Overflow");
        return c;
    }
}

contract UsingLibraries {
    using SafeMath for uint256;  // Attach library to uint256
    
    function calculate(uint256 a, uint256 b) public pure returns (uint256) {
        return a.add(b);  // Calls SafeMath.add(a, b)
    }
}
```

---

## Global Variables & Functions

### Common Global Variables
```solidity
// Block information
block.timestamp  // Current block timestamp
block.number     // Current block number
block.difficulty // Current block difficulty
block.gaslimit   // Current block gas limit

// Transaction information
msg.sender       // Address calling the function
msg.value        // Amount of ETH sent (in wei)
msg.data         // Complete calldata
msg.sig          // First 4 bytes of calldata (function selector)

// Contract information
address(this)           // Current contract address
address(this).balance   // Contract's ETH balance
```

### Common Functions
```solidity
// Type conversions
uint256 x = uint256(someInt);
address addr = address(someUint);

// Address functions
addr.balance                      // ETH balance of address
addr.transfer(1 ether)           // Send ETH (throws on failure)
addr.send(1 ether)               // Send ETH (returns bool)
addr.call{value: 1 ether}("")    // Low-level call

// Cryptographic functions
keccak256(abi.encodePacked(a, b))  // Hash function
ecrecover(hash, v, r, s)            // Recover signer address

// Contract interaction
selfdestruct(payable(addr))        // Destroy contract, send funds
```

---

## Gas Optimization Tips

```solidity
contract GasOptimization {
    // 1. Use uint256 instead of smaller uints (uint8, uint16)
    //    EVM operates on 256-bit words
    uint256 public number;  // Cheaper than uint128
    
    // 2. Use constant and immutable
    uint256 public constant MAX = 1000;    // Compile-time constant
    address public immutable owner;         // Set in constructor
    
    // 3. Pack storage variables
    // Bad - uses 2 storage slots
    uint256 a;  // Slot 0
    uint8 b;    // Slot 1
    
    // Good - uses 1 storage slot
    uint128 c;  // Slot 0
    uint128 d;  // Slot 0 (packed together)
    
    // 4. Cache array length
    function loopExample(uint256[] memory arr) public pure {
        uint256 length = arr.length;  // Cache length
        for (uint256 i = 0; i < length; i++) {
            // Do something
        }
    }
    
    // 5. Use custom errors instead of strings
    error InsufficientBalance();  // Cheaper
    // vs
    // require(balance > 0, "Insufficient balance");  // Expensive
    
    // 6. Use external for functions only called externally
    function externalFunc() external {  // Cheaper than public
        // Logic
    }
}
```

---

## Quick Reference

### Data Location
- `storage` - Permanent (state variables)
- `memory` - Temporary (function variables)
- `calldata` - Read-only parameters

### Function Types
- `public` - Anyone can call
- `external` - Only external calls
- `internal` - This contract + derived
- `private` - Only this contract

### State Mutability
- `view` - Read state only
- `pure` - No state access
- `payable` - Accept ETH
- (no modifier) - Modify state

### Common Imports
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
```
