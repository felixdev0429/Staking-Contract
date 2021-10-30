// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "hardhat/console.sol";

//standard ERC20 tokens for reward token
contract RewardToken is OwnableUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable {
  function initialize() public initializer {
    __Ownable_init();
    __ERC20Burnable_init();
    __ERC20_init("RewardToken", "RTK");
  }

  function mint(address user, uint256 amount)
    public onlyOwner returns (bool) {
      console.log("Minted RewardToken to %s with %s:", user, amount);
      _mint(user, amount);
      return true;
    }
}