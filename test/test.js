const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("SimpleStaking Test", function () {
  let StakeToken;
  let stakeToken;
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

    StakeToken = await ethers.getContractFactory("StakeToken");
    stakeToken = await upgrades.deployProxy(StakeToken, { initializer: 'initialize' });
    await stakeToken.deployed();

    RewardToken = await ethers.getContractFactory("RewardToken");
    rewardToken = await upgrades.deployProxy(RewardToken, { initializer: 'initialize' });
    await rewardToken.deployed();

    StakingContract = await ethers.getContractFactory("SimpleStaking");
    stakingContract = await upgrades.deployProxy(StakingContract, ["0x90F79bf6EB2c4f870365E785982E1f101E93b906"], { initializer: 'initialize' });
    await stakingContract.deployed();

    await stakeToken.connect(owner).mint('0x70997970C51812dc3A010C7d01b50e0d17dc79C8', 10000);
    await stakeToken.connect(owner).mint('0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC', 10000);
    await rewardToken.connect(owner).mint('0x90F79bf6EB2c4f870365E785982E1f101E93b906', 100000);

    await stakeToken.connect(addr1).approve(stakingContract.address, 100000);
    await stakeToken.connect(addr2).approve(stakingContract.address, 100000);

  });
  describe("Deployment", async function () {
    it("Should set the right owner", async function () {
      expect(await stakeToken.owner()).to.equal(owner.address);
    });
  });
  describe("Exception test", function () {
    it("Request amount is less than total amounts", async function () {
      await expect(stakingContract.connect(addr1).stake(stakeToken.address, 10001)).to.be.revertedWith("Request amount is less than total amounts");
    });
    it("Unstaked amount is less than staked amount", async function () {
      await expect(stakingContract.connect(addr1).unstake(stakeToken.address, 1000)).to.be.revertedWith("Unstaked amount is less than staked amount");
    });
    it("Unstaked amounts is less than requested amounts", async function () {
      await expect(stakingContract.connect(addr1).withdrawUnstaked(stakeToken.address, 1000)).to.be.revertedWith("Unstaked amounts is less than requested amounts");
    });
    it("Reward amounts is less than requested amounts", async function () {
      await expect(stakingContract.connect(addr1).withdrawReward(stakeToken.address, 1000)).to.be.revertedWith("Reward amounts is less than requested amounts");
    });
  });
  describe("Test", function () {
    it("Test", async function () {
      await stakingContract.connect(addr1).stake(stakeToken.address, 5000);
      await stakingContract.connect(addr1).unstake(stakeToken.address, 2000);
      await stakingContract.connect(addr1).withdrawUnstaked(stakeToken.address, 1000);
      expect(await stakeToken.balanceOf(stakingContract.address)).to.equal(4000);
      let obj = await stakingContract.records(stakeToken.address,addr1.address);
      expect(obj.stakedAmount).to.equal(3000);
    });
  });

});
