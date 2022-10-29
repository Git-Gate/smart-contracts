const hre = require("hardhat");

async function main() {

  const POGMRegistry = await hre.ethers.getContractFactory("POGMRegistry");
  const registry = await POGMRegistry.deploy();
  await registry.deployed();

  console.log(
    `Registry deployed to ${registry.address}`
  );

  const POGMFactory = await hre.ethers.getContractFactory("POGMFactory");
  const factory = await POGMFactory.deploy(registry.address);

  await factory.deployed();

  console.log(
    `Factory deployed to ${factory.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
