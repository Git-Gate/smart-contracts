# GitGate Smart Contracts - Hardhat Project

## How to run this project

```console
foo@bar:~$ git clone https://github.com/Git-Gate/smart-contracts
foo@bar:~$ cd smart-contracts
foo@bar:~$ npm i
```

Create the .env file and insert the following variables:
- ALCHEMY_URL
- PRIVATE_KEY
- PRIVATE_KEY2

To deploy the smart contracts on the local hardhat network run:
```console
foo@bar:~$ npx hardhat run scripts/deploy.js --network hardhat
```

To deploy the smart contracts on the Mumbai Polygon network run:
```console
foo@bar:~$ npx hardhat run scripts/deploy.js --network mumbai
```
