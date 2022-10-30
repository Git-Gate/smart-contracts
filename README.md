# GitGate Smart Contracts - Hardhat Project

## Contract Addresses

- https://mumbai.polygonscan.com/address/0xd5620C08abe1e0693e7f1c5C0BBc13ca2D729d89
- https://mumbai.polygonscan.com/address/0x000f1FdB610415bd8434515B0F74Ea78E12228BC

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
