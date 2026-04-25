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
Allows storing variable/constants with differents data stuctures. -> project is fully copied

### Storage factory [Cyfrin]
Allows creating simple storage contract from a smart contract -> project is fully copied

### Fund me [Cyfrin]
Small fake crowdfunding project. -> project is fully copied but simplified compared to cyfrin course, removed the oracle

### MiniDao [Me]
The creation of a mini dao smart contract enabling voting, seeing votes, ...

[Foundry]
### Foundry Simple storage [Cyfrin]
The scope of this project is the same as Simple storage but this time we will use foundry to run it. -> project is fully copied

### Foundry Fund me [Cyfrin]
Same as FundMe but used foundry to run it -> project is fully copied

### SimpleLottery [Cyfrin]
Name is explicit, a lottery system ruled by smart contracts. -> project is fully copied

### SimpleDex [Speedrun]
https://github.com/scaffold-eth/se-2-challenges/tree/challenge-dex
Create a dex that enables "balloons" swap with Eth; the project is based on speedrun ethereum but will be done with foundry and without the frontend. -> the only thing done here is simple unit test to discover the test framework and solidity

### StableCoin [Speedrun]
https://github.com/scaffold-eth/se-2-challenges/tree/challenge-stablecoins
Create a decentralized stable coin; the project is based on speedrun ethereum but will be done with foundry and without the frontend.
-> the only thing done here is simple unit test to discover the test framework and solidity

### DaoFactory [Me]
'Continuation' of the miniDao project. The smart contract allows everybody to create its own Dao. Those Dao have their own token, governance, ... The daos also have their own dex that allows swap between eth and DoaToken

### PredictionMarket [Speedrun]
https://github.com/scaffold-eth/se-2-challenges/tree/challenge-prediction-markets
Building and understanding a simple prediction market, where users can buy and sell ERC20 outcome shares based on the result of an event.
-> the only thing done here is simple unit tests, of some function only, to discover the test framework and solidity

## TODOs
- small security smart contracts 'course', a folder with the most well known security problem, an exemple in code, an example on how to exploit (with the deploy script, ...) and a fix.
- Personal project (if no idea: check DaoFactory to see if there are some problems (perf, security, ...))
- cyfrin advanced foundry
- cyfrin smart contracts security
- Solidity x Odoo ?

## Cheatsheets

For detailed cheatsheets, see the [cheatsheets](./cheatsheets/) folder:
- **[Foundry Cheatsheet](./cheatsheets/foundry.md)** - Forge, Anvil, and Cast commands
- **[Solidity Cheatsheet](./cheatsheets/solidity.md)** - Complete Solidity reference with examples
