# SolidityLearning
a repo where I add all the small code I did to learn a bit of solidity

[Cyfrin] = project comes from https://updraft.cyfrin.io/

[Me] = personal project to gather what I learned until that moment

[Remix] = project was done on remix

[Foundry] = project was runned with foundry

### Simple storage [Cyfrin][Remix]
Allows storing variable/constants with differents data stuctures.

### Storage factory [Cyfrin][Remix]
Allows creating simple storage contract from a smart contract

### Fund me [Cyfrin][Remix]
Small fake crowdfunding project. (simplified compared to cyfrin course, removed the oracle)

### MiniDao [Me][Remix]
The creation of a mini dao smart contract enabling voting, seeing votes, ...

### Foundry Simple storage [Cyfrin][Foundry]
The scope of this project is the same as Simple storage but this time we will use foundry to run it.

### Foundry Fund me [Cyfrin][Foundry]
Same as FundMe but used foundry to run it

Create a new project with: forge init (--use-parent-git)

in another terminal, with wsl/
- To run local blockchain: anvil

on project folder, with wsl:
- To compile: forge compile
- To deploy contract: forge create ContractName --rpc-url HTTP://127.0.0.1:8545 --private-key xxxx (or --interactive)(find private key and url on anvil)  ==> private key here is only with test ones, NEVER do this with a real one, interactive is better
- To deploy with a script (in temp blockchain, dleted afterward): forge script script/DeploySimpleStorage.s.sol
- To simulate deployment on anvil: forge script script/DeploySimpleStorage.s.sol --rpc-url HTTP://127.0.0.1:8545
- To deploy on anvil: forge script script/DeploySimpleStorage.s.sol:DeploySimpleStorage --rpc-url HTTP://127.0.0.1:8545 --broadcast --private-key xxxx

Cast
- store a private key: cast wallet import defaultKey --interactive
    - list them all: cast wallet list
    - usage: use --account defaultKey --sender xxxsenderPublicAddressxxx instead of --private-key
- process transaction: cast send xxxsenderAddressxxx "fctName(argsType)" args --rpc-url URL --private-key KEY
- read on blockchain: cast call xxxsenderAddressxxx "fctName(argsType)" args


-run unit tests: forge test (-vvvvv)
