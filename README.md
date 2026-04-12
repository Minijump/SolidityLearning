# SolidityLearning
## Mini Projects
a repo where I add all the small code I did to learn a bit of solidity

[Cyfrin] = project comes from https://updraft.cyfrin.io/

[Speedrun] = project comes from https://speedrunethereum.com/

[Me] = personal project to gather what I learned until that moment

[Remix] = project was done on remix

[Foundry] = project was runned with foundry

[Remix]
### Simple storage [Cyfrin]
Allows storing variable/constants with differents data stuctures.

### Storage factory [Cyfrin]
Allows creating simple storage contract from a smart contract

### Fund me [Cyfrin]
Small fake crowdfunding project. (simplified compared to cyfrin course, removed the oracle)

### MiniDao [Me]
The creation of a mini dao smart contract enabling voting, seeing votes, ...

[Foundry]
### Foundry Simple storage [Cyfrin]
The scope of this project is the same as Simple storage but this time we will use foundry to run it.

### Foundry Fund me [Cyfrin]
Same as FundMe but used foundry to run it

### SimpleLottery [Cyfrin]
Name is explicit, a lottery system ruled by smart contracts.

### SimpleDex [Speedrun]
https://github.com/scaffold-eth/se-2-challenges/tree/challenge-dex
Create a dex that enables "balloons" swap with Eth; the project is based on speedrun ethereum but will be done with foundry and without the frontend. -> the only thing done here is simple unit test to discover the test framework and solidity

### StableCoin [Speedrun]
https://github.com/scaffold-eth/se-2-challenges/tree/challenge-stablecoins
Create a decentralized stable coin; the project is based on speedrun ethereum but will be done with foundry and without the frontend.
-> the only thing done here is simple unit test to discover the test framework and solidity

### DaoFactory [Me]
'Continuation' of the miniDao project. The smart contract allows everybody to create its own Dao. Those Dao have their own token, governance, ... The daos also have their own dex that allows swap between eth and DoaToken

## TODOs
- [speedrun eth prediction market](https://speedrunethereum.com/challenge/prediction-markets)
- cyfrin advanced foundry

## Cheatsheet

### Foundry Tools Overview
Foundry is a toolkit with three main tools:
- **Forge**: The build system and testing framework. Use it to compile, test, deploy contracts, and manage dependencies.
- **Anvil**: A local Ethereum node (like Ganache). Run it to have a fast blockchain for development and testing.
- **Cast**: A command-line tool to interact with contracts and blockchain. Use it to send transactions, read contract state, query blockchain data, convert values, and manage wallets.

In short: **Forge** builds and tests, **Anvil** runs the blockchain, **Cast** interacts with it.

### Forge Project Setup
- Create new project: `forge init [--use-parent-git] [--empty] [--force]`
- Install dependencies: `forge install org/repo` (e.g., `forge install OpenZeppelin/openzeppelin-contracts`)
- Update dependencies: `forge update`
- Remove dependencies: `forge remove dependency-name`

### Forge Local Development
- Format code: `forge fmt`
- Clean build artifacts: `forge clean`

### Forge Testing
- Run all tests: `forge test`
- Run with verbosity: `forge test -vvvv` (more v's = more details)
- Run specific test: `forge test --match-test testName`
- Run tests in file: `forge test --match-path test/File.t.sol`
- Show gas report: `forge test --gas-report`
- Generate coverage: `forge coverage`
- Save gas snapshot: `forge snapshot`

### Forge Debugging & Analysis
- Inspect storage layout: `forge inspect ContractName storageLayout`
- Get contract ABI: `forge inspect ContractName abi`
- Flatten contract: `forge flatten src/Contract.sol`
- Verify contract: `forge verify-contract 0xADDRESS ContractName --chain chainId --etherscan-api-key KEY`

### Forge Deployment
- Compile contracts: `forge compile` (or `forge build`)
- Quick deploy: `forge create ContractName --rpc-url http://127.0.0.1:8545 --private-key 0xKEY`
- Deploy with script (dry-run): `forge script script/DeployContract.s.sol`
- Deploy with script (simulate): `forge script script/DeployContract.s.sol --rpc-url http://127.0.0.1:8545`
- Deploy with script (execute): `forge script script/DeployContract.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key 0xKEY`
NEVER write a real private key in terminal`

### Anvil (Local Blockchain)
- Start with default settings: `anvil`
- Start with specific port: `anvil --port 8546`
- Start with specific accounts: `anvil --accounts 15`
- Fork a network: `anvil --fork-url https://eth-mainnet.alchemyapi.io/v2/YOUR_KEY`
- Set chain ID: `anvil --chain-id 1337`
- Set block time: `anvil --block-time 5` (produces block every 5 seconds)

### Cast (Wallet & Transactions)
- Import private key: `cast wallet import keyName --interactive`
- List imported keys: `cast wallet list`
- Use imported key: `--account keyName --sender 0xADDRESS` (instead of `--private-key`)
- Send transaction: `cast send 0xCONTRACT "functionName(type1,type2)" arg1 arg2 --rpc-url URL --private-key 0xKEY`
- Read from contract: `cast call 0xCONTRACT "functionName(type1)" arg1`
- Get balance: `cast balance 0xADDRESS --rpc-url URL`
- Convert hex to decimal: `cast to-dec 0xHEX`
- Convert decimal to hex: `cast to-hex 123
