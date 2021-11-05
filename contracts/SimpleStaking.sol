// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "hardhat/console.sol";

//Staking Contract
contract SimpleStaking is Initializable, OwnableUpgradeable, PausableUpgradeable {

  address public rwTokenAddr;//reward token address
  uint256 public rewardInterval;
  
  struct Record {
    uint256 stakedAmount;
    uint256 stakedAt;
    uint256 unstakedAmount;
    uint256 unstakedAt;
    uint256 rewardAmount;
  }

  //for "records", a mapping of token addresses and user addresses to an user Record struct
  mapping(address => mapping(address => Record)) public records;
  //for "rewardRates", a mapping of token address to reward rates. e.g. if APY is 20%, then rewardRate is 20.
  mapping(address => uint) public rewardRates;

  ///@notice Event emitted when user stake
  event Stake(address indexed user, uint256 amount, uint256 stakedAt);

  ///@notice Event emitted when user unstake
  event Unstake(address indexed user, uint256 amount, address indexed tokenAddr, uint256 reward, uint256 unstakedAt);
  
  ///@notice Event emitted when user withdrawl unstaked token
  event WithdrawUnstaked(address indexed user, uint256 amount, uint256 withdrawAt);
  
  ///@notice Event emitted when user withdrawl their reward token
  event WithdrawRewards(address indexed user, uint256 amount, uint256 withdrawAt);
  
  ///@notice Event emitted when owner set reward rate for user
  event SetRewardRate(address indexed tokenAddr, uint256 newRewardRate);

  ///@notice Event emitted when owner set reward internal time
  ///event SetRewardInternal(uint256 _rewardInternal);

  ///@notice Event emitted when owner set the reward Token address
  event SetRewardTokenAddr(address _rewardTokenAddr);
  
  /**
    * @dev initialize function
    * @param _rwTokenAddr address of reward token
    */
  function initialize(address _rwTokenAddr) external initializer {
    __Ownable_init();
    __Pausable_init();
    rewardInterval = 1 hours;
    rwTokenAddr = _rwTokenAddr;
  }

  /**
    * @dev external function for users to stake tokens
    * @param tokenAddr address of Staketoken
    * @param amount amount of Staketoken
    */
  function stake(address tokenAddr, uint256 amount) external whenNotPaused {
    IERC20Upgradeable stackToken = IERC20Upgradeable(tokenAddr);
    require(stackToken.balanceOf(msg.sender) >= amount,
        "Request amount is less than total amounts"
    );

    if (amount == 0) {
        amount = stackToken.balanceOf(msg.sender);
        stackToken.transferFrom(msg.sender, address(this), amount);
    } else {
        stackToken.transferFrom(msg.sender, address(this), amount);
    }
    
    records[tokenAddr][msg.sender].stakedAmount += amount;
    records[tokenAddr][msg.sender].stakedAt = block.timestamp;
    records[tokenAddr][msg.sender].rewardAmount = calculateReward(tokenAddr, msg.sender, amount);//when stake, it is 0 by default.

    console.log("Token address %s was staked %s by %s", tokenAddr, amount, msg.sender);
    
    emit Stake(tokenAddr, amount, block.timestamp);
  }

  /**
    * @dev external function for users to unstake their staked tokens
    * @param tokenAddr address of Staketoken
    * @param amount amount of Staketoken
    */
  function unstake(address tokenAddr, uint256 amount) external whenNotPaused {
    require(records[tokenAddr][msg.sender].stakedAmount >= amount,
        "Unstaked amount is less than staked amount"
    );
    if(amount == 0) {
        records[tokenAddr][msg.sender].unstakedAmount = records[tokenAddr][msg.sender].stakedAmount;
        records[tokenAddr][msg.sender].stakedAmount = 0;
    } else {
        records[tokenAddr][msg.sender].stakedAmount -= amount;
        records[tokenAddr][msg.sender].unstakedAmount += amount;
    }
    
    records[tokenAddr][msg.sender].unstakedAt = block.timestamp;
    records[tokenAddr][msg.sender].rewardAmount = calculateReward(tokenAddr, msg.sender, records[tokenAddr][msg.sender].stakedAmount);

    console.log("Token address %s was unstaked %s by %s", tokenAddr, amount, msg.sender);

    emit Unstake(msg.sender, amount, tokenAddr, records[tokenAddr][msg.sender].rewardAmount, block.timestamp);
  }

  /**
    * @dev external function for users to withdraw their unstaked tokens from this contract to the caller's address
    * @param tokenAddr address of Staketoken
    * @param _amount amount of Staketoken
    */
  function withdrawUnstaked(address tokenAddr, uint256 _amount) external whenNotPaused {
    require(records[tokenAddr][msg.sender].unstakedAmount >= _amount,
        "Unstaked amounts is less than requested amounts"
    );

    uint256 emitAmount;
    IERC20Upgradeable stakeToken = IERC20Upgradeable(tokenAddr);
    if (_amount == 0) {
        emitAmount = records[tokenAddr][msg.sender].unstakedAmount;
        stakeToken.transfer(msg.sender, emitAmount);
        records[tokenAddr][msg.sender].unstakedAmount = 0;
    } else {
        records[tokenAddr][msg.sender].unstakedAmount -= _amount;
        emitAmount = _amount;
        stakeToken.transfer(msg.sender, emitAmount);
    }

    console.log("Unstaked Tokens %s was withdrawal %s by %s", tokenAddr, emitAmount, msg.sender);

    emit WithdrawUnstaked(msg.sender, emitAmount, block.timestamp);
  }

  /**
    * @dev external function for users to withdraw reward tokens from this contract to the caller's address
    * @param tokenAddr address of Staketoken
    * @param _amount amount of Staketoken
    */
  function withdrawReward(address tokenAddr, uint256 _amount) external whenNotPaused {
    require(records[tokenAddr][msg.sender].rewardAmount >= _amount,
        "Reward amounts is less than requested amounts"
    );
    require(rewardInterval >= (records[tokenAddr][msg.sender].stakedAt - block.timestamp),
        "Reward time is finished yet"
    );
    
    uint256 emitAmount;
    IERC20Upgradeable rewardToken = IERC20Upgradeable(rwTokenAddr);
    if(_amount == 0) {
        emitAmount = records[tokenAddr][msg.sender].rewardAmount;
        rewardToken.transfer(msg.sender, emitAmount);
        records[tokenAddr][msg.sender].rewardAmount = 0;
    } else {
        records[tokenAddr][msg.sender].rewardAmount -= _amount;
        emitAmount = _amount;
        rewardToken.transfer(msg.sender, emitAmount);
    }
    records[tokenAddr][msg.sender].stakedAt = block.timestamp;

    console.log("Reward Tokens %s was withdrawal %s by %s", tokenAddr, emitAmount, msg.sender);

    emit WithdrawRewards(msg.sender, emitAmount, block.timestamp);
  }

  /**
    * @dev public function to calculate rewards based on the duration of staked tokens, staked token amount, reward rate of the staked token, reward interval
    * @param tokenAddr address of StakeToken
    * @param user address of user
    * @param _amount amount of Staketoken
    */
  function calculateReward(address tokenAddr, address user, uint256 _amount) public view returns (uint256) {
    return (((block.timestamp - records[tokenAddr][user].stakedAt) / rewardInterval) * _amount) * rewardRates[tokenAddr] / 100;
  }

  /**
    * @dev external function for this contract owner to set the reward rate of a staked token
    * @param tokenAddr address of Staketoken
    * @param rewardRate amount of reward rate. if it is 20%, reward rate is 20.
    */
  function setRewardRate(address tokenAddr, uint256 rewardRate) external onlyOwner {
    rewardRates[tokenAddr] = rewardRate;
    emit SetRewardRate(tokenAddr, rewardRate);
  }

  /**
    * @dev external function for owner to pause this contract
    */
  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  /**
    * @dev external function for owner to unpause this contract
    */
  function unpause() external onlyOwner whenPaused {
    _unpause();
  }

  /**
    * @dev external function only for this contract owner to set the reward token address
    * @param _rewardTokenAddr address of reward token
    */
  function setRewardTokenAddr(address _rewardTokenAddr) external onlyOwner {
    rwTokenAddr = _rewardTokenAddr;
    emit SetRewardTokenAddr(_rewardTokenAddr);
  }

}