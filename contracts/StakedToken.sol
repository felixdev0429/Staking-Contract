// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "hardhat/console.sol";

//standard ERC20 tokens for staked token
contract StakedToken is OwnableUpgradeable, ERC20Upgradeable, ERC20BurnableUpgradeable {
  function initialize() public initializer {
    __Ownable_init();
    __ERC20Burnable_init();
    __ERC20_init("StakeToken", "STK");
  }

  function mint(address user, uint256 amount)
    public onlyOwner returns (bool) {
      console.log("Minted StakedToken to %s with %s:", user, amount);
      _mint(user, amount);
      return true;
    }
}