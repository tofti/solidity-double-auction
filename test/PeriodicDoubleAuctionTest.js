const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");

const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

async function fundNewRandomWallet() {
  const [owner] = await ethers.getSigners();
  wallet = ethers.Wallet.createRandom().connect(ethers.provider);
  await owner.sendTransaction({
    to: wallet.address,
    value: ethers.utils.parseEther("1.0"),
  });
  return wallet;
}

describe("PeriodicDoubleAuction", function () {
  let periodicAuction;
  let baseAssetContract;
  let quoteAssetContract;

  beforeEach(async function () {
    await bootstrapERC20s();
    periodicAuction = await deploy();
  });

  async function bootstrapERC20s() {
    factory = await ethers.getContractFactory("BaseAsset");
    baseAssetContract = await factory.deploy(1000000);
    await baseAssetContract.deployTransaction.wait();

    factory = await ethers.getContractFactory("QuoteAsset");
    quoteAssetContract = await factory.deploy(1000000);
    await quoteAssetContract.deployTransaction.wait();
  }

  async function deploy() {
    periodicAuctionImplFactory = await ethers.getContractFactory(
      "PeriodicDoubleAuctionImpl"
    );
    periodicAuction = await periodicAuctionImplFactory.deploy(
      "test_name",
      baseAssetContract.address,
      quoteAssetContract.address
    );
    await periodicAuction.deployTransaction.wait();
    return periodicAuction;
  }

  describe("Deployment", function () {
    it("correctly report the base and quote assets", async function () {
      reportedBaseAsset = await periodicAuction.baseAsset();
      expect(reportedBaseAsset).to.equal(baseAssetContract.address);

      reportedQuoteAsset = await periodicAuction.quoteAsset();
      expect(reportedQuoteAsset).to.equal(quoteAssetContract.address);
    });
    // TODO test failure cases
  });

  describe("Funding", function () {
    it("should permit a deposit of an ERC20 token", async function () {
      const baseAssetAmount = 1000;
      const [owner] = await ethers.getSigners();

      // create an EOA and fund it with some eth
      wallet = await fundNewRandomWallet();

      // transfer some base asset in to it, and verify the balance
      await baseAssetContract.transfer(wallet.address, baseAssetAmount);
      baseAssetBalance = await baseAssetContract.balanceOf(wallet.address);
      expect(baseAssetBalance).to.equal(baseAssetAmount);

      // give the auction contract some base asset allowance, and verify
      await baseAssetContract
        .connect(wallet)
        .approve(periodicAuction.address, baseAssetAmount);
      expect(
        await baseAssetContract
          .connect(wallet)
          .allowance(wallet.address, periodicAuction.address)
      ).to.equal(baseAssetAmount);

      // have the EOA deposit in to the auction contract, and verify the Deposit event
      tx = await periodicAuction
        .connect(wallet)
        .deposit(baseAssetContract.address, baseAssetAmount);
      txr = await tx.wait();
      depositEvent = txr.events.find((event) => event.event === "Deposit");
      expect(depositEvent.args).to.deep.equal([
        baseAssetContract.address,
        ethers.BigNumber.from(baseAssetAmount),
      ]);

      // verify the wallet's balance of base asset as reported by the auction
      expect(
        await periodicAuction.connect(wallet).balance(baseAssetContract.address)
      ).to.equal(baseAssetAmount);
    });
    // TODO test failure cases
  });

  describe("Place bids and offers", function () {
    it("should permit a bid when a wallet has a balance", async function () {
      expect(await periodicAuction.connect(wallet).numberOfBids()).to.equal(0);

      // EOA will place a bid for 10 units of base amount at a price of 5
      // therefore requires 50 units of quote asset to purchase
      const size = 10;
      const price = 5;
      const quoteAssetAmountRequired = size * price;
      // create a wallet
      wallet = await fundNewRandomWallet();

      // transfer some quote asset to the wallet
      await quoteAssetContract.transfer(
        wallet.address,
        quoteAssetAmountRequired
      );

      // have the wallet approve the periodic auction contract for spending the token
      await quoteAssetContract
        .connect(wallet)
        .approve(periodicAuction.address, quoteAssetAmountRequired);

      // make a deposit
      tx = await periodicAuction
        .connect(wallet)
        .deposit(quoteAssetContract.address, quoteAssetAmountRequired);
      await tx.wait();

      // verify the balance of the quote asset
      availableBalance = await periodicAuction
        .connect(wallet)
        .balance(quoteAssetContract.address);
      expect(availableBalance).to.equal(quoteAssetAmountRequired);

      // place a bid
      tx = await periodicAuction.connect(wallet).placeBid(size, price);
      txr = await tx.wait();
      bidEvent = txr.events.find((evt) => evt.event === "Bid");
      expect(bidEvent.args).to.deep.equal([wallet.address, size, price]);

      expect(await periodicAuction.connect(wallet).numberOfBids()).to.equal(1);

      // verify the balance of the quote asset is now zero
      availableBalance = await periodicAuction
        .connect(wallet)
        .balance(quoteAssetContract.address);
      expect(availableBalance).to.equal(0);
    });
  });
});
