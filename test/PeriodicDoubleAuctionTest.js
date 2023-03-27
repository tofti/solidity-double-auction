const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("PeriodicDoubleAuction", function () {
  let periodicAuction
  let baseAsset
  let quoteAsset

  beforeEach(async function () {
    await bootstrapERC20s()
    periodicAuction = await deploy()
  })

  async function bootstrapERC20s() {
    factory = await ethers.getContractFactory("BaseAsset")
    deployResult = await factory.deploy(1000000)
    deployTransaction = deployResult.deployTransaction
    console.log(`baseAsset => ${deployTransaction.creates}`)
    baseAsset = deployTransaction.creates

    factory = await ethers.getContractFactory("QuoteAsset")
    deployResult = await factory.deploy(1000000)
    deployTransaction = deployResult.deployTransaction
    console.log(`quoteAsset => ${deployTransaction.creates}`)
    quoteAsset = deployTransaction.creates
  }

  async function deploy() {
    periodicAuctionImplFactory = await ethers.getContractFactory("PeriodicDoubleAuctionImpl")
    periodicAuction = await periodicAuctionImplFactory.deploy(
      "test_name",
      baseAsset,
      quoteAsset
    )
    periodicAuctionDeployTransaction = periodicAuction.deployTransaction
    console.log(`auction contract => ${periodicAuctionDeployTransaction.creates}`)
    return periodicAuction
  }

  describe("Deployment", function () {
    it("correctly report the base and quote assets", async function () {
      console.log(`${typeof(periodicAuction)} ${periodicAuction.getOwnPropertyDescriptors()}`)
      reportedBaseAsset = await periodicAuction.baseAsset()
      console.log(`reported base asset => ${reportedBperiodicAuctionaseAsset}`)
    });

    it("Should permit a deposit of an ERC20 token", async function() {

    })

  });
});
