require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  networks: {
    hardhat: {
      // mining: {
      //   auto: false,
      //   interval: [10000, 20000]
      // },
      forking: {
        url: process.env.ALCHEMY_URL,
        accounts: [
          process.env.PRIVATE_KEY,
          process.env.PRIVATE_KEY2,
          process.env.PRIVATE_KEY3,
          process.env.PRIVATE_KEY4,
        ],
      },
    },
    mumbai: {
      url: process.env.ALCHEMY_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    development: {
      url: "http://127.0.0.1:8545/",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: "VSDP3JH47RIZJWXYQHI6XFWP9A8M7XDYPQ",
  },
};
