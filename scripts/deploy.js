// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const StakedToken = await hre.ethers.getContractFactory("StakedToken");
  //stakedToken = await StakedToken.deploy();
  stakedTokenUpgrades = await upgrades.deployProxy(StakedToken, { initializer: 'initialize' });
  //await stakedToken.deployed();
  await stakedTokenUpgrades.deployed();
  //console.log("StakedToken address:", stakedToken.address);
  console.log("StakedTokenUpgrades address:", stakedTokenUpgrades.address);

  const RewardToken = await hre.ethers.getContractFactory("RewardToken");
  //rewardToken = await RewardToken.deploy();
  rewardTokenUpgrades = await upgrades.deployProxy(RewardToken, { initializer: 'initialize' });
  //await rewardToken.deployed();
  await rewardTokenUpgrades.deployed();
  //console.log("RewardToken address:", rewardToken.address);
  console.log("RewardTokenUpgrades address:", rewardTokenUpgrades.address);

  StakingContract = await hre.ethers.getContractFactory("SimpleStaking");
  //stakingContract = await StakingContract.deploy('0xEE2DDda9A2ad3a9397fAaAC30Bc6B18596B4AfA6');
  stakingContractUpgrades = await upgrades.deployProxy(StakingContract, ["0xEE2DDda9A2ad3a9397fAaAC30Bc6B18596B4AfA6"], { initializer: 'initialize' });
  //await stakingContract.deployed();
  await stakingContractUpgrades.deployed();
  //console.log("RewardToken address:", stakingContract.address);
  console.log("stakingContractUpgrades address:", stakingContractUpgrades.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
