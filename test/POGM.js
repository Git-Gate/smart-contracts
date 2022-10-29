const helpers = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("POGM", function () {
  async function deploy() {
    const POGMRegistry = await hre.ethers.getContractFactory("POGMRegistry");
    const registry = await POGMRegistry.deploy();
    await registry.deployed();

    // console.log(
    //   `Registry deployed to ${registry.address}`
    // );

    const POGMFactory = await hre.ethers.getContractFactory("POGMFactory");
    const factory = await POGMFactory.deploy(registry.address);

    await factory.deployed();

    // console.log(
    //   `Factory deployed to ${factory.address}`
    // );

    const user_has_access = "0x4AC7fcF17B690b600c86C2e6049850663270E3C2";
    const user_has_not_access = "0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B";

    const ERC20Factory = await hre.ethers.getContractFactory("MyTokenERC20");
    const erc20token = await ERC20Factory.deploy(user_has_access);
    await erc20token.deployed();

    const ERC721Factory = await hre.ethers.getContractFactory("MyTokenERC721");
    const erc721token = await ERC721Factory.deploy(user_has_access);
    await erc721token.deployed();

    const ERC1155Factory = await hre.ethers.getContractFactory("MyTokenERC1155");
    const erc1155token = await ERC1155Factory.deploy(user_has_access);
    await erc1155token.deployed();

    let erc20address = erc20token.address
    let erc721address = erc721token.address
    let erc1155address = erc1155token.address

    return { registry, factory, erc20address, erc721address, erc1155address, user_has_access, user_has_not_access };
  }

  it.only("create new tokenized repo", async function () {

    const { registry, factory } = await helpers.loadFixture(deploy);

    const [deployer, impersonatedSigner] = await ethers.getSigners();

    const hashed_message = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("67890_" + impersonatedSigner.address));
    const messageBytes = ethers.utils.arrayify(hashed_message);
    const signature = await impersonatedSigner.signMessage(messageBytes);

    const repository = {
      githubRepoId: 315742009,
      operators: [impersonatedSigner.address, '0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B', '0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B'],
      op: [0, 1, 2],
      blacklistedAddresses: [],
      collections: ["0x0000000000000000000000000000000000000000"],
      ids: [ethers.BigNumber.from("0xc2132D05D31c914a87C6611C10748AEb04B58e8F")],
      amounts: [ethers.utils.parseUnits("121.0", 6)],
      soulBoundTokenContract: "0xc0ffee254729296a45a3885639AC7E10F9d54979",
      tokenizedRepoName: "",
      soulboundBaseURI: ""
    }

    let tx = await registry.createTokenizedRepo(repository, messageBytes, signature);
    let receipt = await tx.wait();
    console.log(messageBytes, signature);
  });

  it("create new tokenized repo MUMBAI", async function () {

    const POGMRegistry = await hre.ethers.getContractFactory("POGMRegistry");
    const registry = await POGMRegistry.attach("0x40D61DEAf5CD0A014945da721dc2D08B53bDEb44");

    const [impersonatedSigner] = await ethers.getSigners();

    const hashed_message = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("435812842_" + impersonatedSigner.address));
    const messageBytes = ethers.utils.arrayify(hashed_message);
    const signature = await impersonatedSigner.signMessage(messageBytes);
    console.log(ethers.utils.verifyMessage(hashed_message, signature))

    const repository = {
      githubRepoId: 435812842,
      operators: [impersonatedSigner.address, '0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B', '0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B'],
      op: [0, 1, 2],
      blacklistedAddresses: [],
      collections: ["0x0000000000000000000000000000000000000000"],
      ids: [ethers.BigNumber.from("0xc2132D05D31c914a87C6611C10748AEb04B58e8F")],
      amounts: [ethers.utils.parseUnits("121.0", 6)],
      soulBoundTokenContract: "0xc0ffee254729296a45a3885639AC7E10F9d54979",
      tokenizedRepoName: "",
      soulboundBaseURI: ""
    }

    let tx = await registry.createTokenizedRepo(repository, messageBytes, signature);
    let receipt = await tx.wait();
  });

  it("create new tokenized repo with wrong signature MUMBAI", async function () {

    const POGMRegistry = await hre.ethers.getContractFactory("POGMRegistry");
    const registry = await POGMRegistry.attach("0xeee45A3BDd197009adc1B403B0C2e3f5e0130820");

    const [impersonatedSigner] = await ethers.getSigners();

    const hashed_message = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("67890_" + impersonatedSigner.address));
    const messageBytes = ethers.utils.arrayify(hashed_message);
    const signature = await impersonatedSigner.signMessage(messageBytes);

    const repository = {
      githubRepoId: 315742009,
      operators: ['0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B', '0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B', '0xab9c5640B9c8484783fc416aA041Ab174cdb3f9B'],
      op: [0, 1, 2],
      blacklistedAddresses: [],
      collections: ["0x0000000000000000000000000000000000000000"],
      ids: [ethers.BigNumber.from("0xc2132D05D31c914a87C6611C10748AEb04B58e8F")],
      amounts: [ethers.utils.parseUnits("121.0", 6)],
      soulBoundTokenContract: "0xc0ffee254729296a45a3885639AC7E10F9d54979",
      tokenizedRepoName: "",
      soulboundBaseURI: ""
    }

    let tx = await registry.createTokenizedRepo(repository, messageBytes, signature);
    let receipt = await tx.wait();
    console.log(messageBytes, signature);
  });

  it("create tokenized repo with wrong signature", async function () {

    const { registry, factory } = await helpers.loadFixture(deploy);

    const [deployer, impersonatedSigner] = await ethers.getSigners();

    const hashed_message = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("67890_" + impersonatedSigner.address));
    const messageBytes = ethers.utils.arrayify(hashed_message);
    const signature = await deployer.signMessage(messageBytes);

    const repository = {
      githubRepoId: 67890,
      operators: [impersonatedSigner.address, impersonatedSigner.address, impersonatedSigner.address],
      op: [0, 1, 2],
      blacklistedAddresses: ["0x5a673baD16A959502582bAdb8AAB4E93317FBBc0"],
      collections: ["0x0000000000000000000000000000000000000000"],
      ids: [ethers.BigNumber.from("0xc2132D05D31c914a87C6611C10748AEb04B58e8F")],
      amounts: [ethers.utils.parseUnits("121.0", 6)],
      soulBoundTokenContract: "0xc0ffee254729296a45a3885639AC7E10F9d54979",
      tokenizedRepoName: "",
      soulboundBaseURI: ""
    }

    let tx = await registry.createTokenizedRepo(repository, messageBytes, signature);
    let receipt = await tx.wait();
    // console.log(receipt);
  });

  it("check user requirements", async function () {

    const { registry, erc20address, erc721address, erc1155address, user_has_access, user_has_not_access } = await helpers.loadFixture(deploy);

    const repoID = 67890;

    const [deployer, impersonatedSigner] = await ethers.getSigners();

    const hashed_message = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(repoID.toString() + "_" + impersonatedSigner.address));
    const messageBytes = ethers.utils.arrayify(hashed_message);
    const signature = await impersonatedSigner.signMessage(messageBytes);

    let erc20Contract = erc20address;
    let erc20quantity = ethers.utils.parseUnits("121.0", 18);
    let erc721Contract = erc721address;
    let erc721quantity = [1, 1, 1, 1];
    let erc721ids = [0, 1, 2, 3];
    let erc1155Contract = erc1155address;
    let erc1155quantity = [2, 4, 3, 2];
    let erc1155ids = [0, 1, 2, 3];

    const repository = {
      githubRepoId: repoID,
      operators: [impersonatedSigner.address, impersonatedSigner.address, impersonatedSigner.address],
      op: [0, 1, 2],
      blacklistedAddresses: ["0x5a673baD16A959502582bAdb8AAB4E93317FBBc0"],
      collections: ["0x0000000000000000000000000000000000000000", erc721Contract, erc721Contract, erc721Contract, erc721Contract, erc1155Contract, erc1155Contract, erc1155Contract, erc1155Contract],
      ids: [ethers.BigNumber.from(erc20Contract), ...erc721ids, ...erc1155ids],
      amounts: [erc20quantity, ...erc721quantity, ...erc1155quantity],
      soulBoundTokenContract: "0xc0ffee254729296a45a3885639AC7E10F9d54979",
      tokenizedRepoName: "TEST",
      soulboundBaseURI: "ipfs://bafkreidbbegtpatz7axjkmetyrc6auwqodzj4nzoaddwifzgx7ycsubtgu"
    }

    let tx = await registry.createTokenizedRepo(repository, messageBytes, signature);
    await tx.wait();

    tx = await registry.checkUserRequirements(repoID, user_has_access);
    expect(tx).to.be.true;
    tx = await registry.checkUserRequirements(repoID, user_has_not_access);
    expect(tx).to.be.false;
  });
});
