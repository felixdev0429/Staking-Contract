# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

## Goal of the contract
Implement a Staking contract that will block the staked tokens for a period of time.
The address of the ERC20 token must be set at deployment.

> Deliverables
- made the following functions to accept amount == 0: stake(), unstake(), withdrawUnstaked(), withdrawReward(), calculateReward(); If amount is zero, then the smart contract should adjust the amount value to be the maximum available value. For example, if _amount is zero for stake() function, then the smart contract should use maximum available value for _amount, which is the caller's token balance.
- Include a deployment script.

