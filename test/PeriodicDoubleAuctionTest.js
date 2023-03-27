const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("PeriodicDoubleAuction", function () {
  beforeEach(async function () {
    console.log("before each")
    periodicAuctionImplFactory = await ethers.getContractFactory("PeriodicDoubleAuctionImpl")
    periodicAuction = await periodicAuctionImplFactory.deploy("fudge")
    console.log(periodicAuction)
  })

  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function fixture() {
    console.log("here is a fixture")
  }

  describe("Deployment", function () {
    it("Should do something", async function () {
      fixture()
      console.log("it should")
    });
    
  });
});
