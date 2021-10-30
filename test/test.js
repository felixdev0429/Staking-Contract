const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("SimpleStaking Test", function () {
  let StakedToken;
  let stakedToken;
  let RewardToken;
  let rewardToken;
  let StakingContract;
  let stakingContract;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  before(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    StakedToken = await ethers.getContractFactory("StakedToken");
    stakedToken = await upgrades.deployProxy(StakedToken, { initializer: 'initialize' });
    await stakedToken.deployed();

    RewardToken = await ethers.getContractFactory("RewardToken");
    rewardToken = await upgrades.deployProxy(RewardToken, { initializer: 'initialize' });
    await rewardToken.deployed();

    StakingContract = await ethers.getContractFactory("SimpleStaking");
    stakingContract = await upgrades.deployProxy(StakingContract, ["0x90F79bf6EB2c4f870365E785982E1f101E93b906"], { initializer: 'initialize' });
    await stakingContract.deployed();

    await stakedToken.connect(owner).mint('0x70997970C51812dc3A010C7d01b50e0d17dc79C8', 10000);
    await stakedToken.connect(owner).mint('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', 10000);
    await rewardToken.connect(owner).mint('0x90F79bf6EB2c4f870365E785982E1f101E93b906', 100000);

    await stakedToken.connect(addr1).approve(stakingContract.address, 100000);
    await stakedToken.connect(addr2).approve(stakingContract.address, 100000);
    await rewardToken.connect(addrs[0]).approve(stakingContract.address, 100000);

  });
  describe("Deployment", async function () {
    it("Should set the right owner", async function () {
      expect(await stakedToken.owner()).to.equal(owner.address);
    });
  });
  describe("Test", function () {
    it("Test", async function () {
      await stakingContract.connect(addr1).stake(stakedToken.address, 5000);
      await stakingContract.connect(addr1).unstake(stakedToken.address, 2000);
      await stakingContract.connect(addr1).withdrawUnstaked(stakedToken.address, 1000);
      expect(await stakedToken.balanceOf(stakingContract.address)).to.equal(4000);
      //expect(await stakingContract.records[stakedToken.address][addr1].stakedAmount).to.equal(3000);
    });
  });

});
