// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "../src/tokenPIG.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StakingApp is Ownable {
    // variables
    address public tokenpig;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewards;

    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public depositTime;
    mapping(address => bool) public rewardsHasClaim;

    // events
    event new_stake_(address, uint256);
    event witrawTokens_(address, uint256);
    event claimRewards_(address, uint256);
    event setStakingAmount_(address, uint256);
    event setStakingPeriod_(address, uint256);
    event addFoundsForRewards_(address, uint256);
    // modifiers

    // constructor

    constructor(
        address tokenpig_,
        uint256 stakingPeriod_,
        uint256 fixedStakingAmount_,
        address owner_,
        uint256 rewards_
    ) Ownable(owner_) {
        tokenpig = tokenpig_;
        stakingPeriod = stakingPeriod_;
        fixedStakingAmount = fixedStakingAmount_;
        rewards = rewards_;
    }

    // external functions

    /**
     * @dev new staking
     * @param amount_ amount tokens staking
     */
    function new_staking(uint256 amount_) external {
        require(amount_ == fixedStakingAmount, "Incorrect amount");
        require(userBalance[msg.sender] == 0, "Staking limit exceeded");

        IERC20(tokenpig).transferFrom(msg.sender, address(this), amount_);
        userBalance[msg.sender] += amount_;
        depositTime[msg.sender] = block.timestamp;
        emit new_stake_(msg.sender, amount_);
    }

    /**
     * @dev withraw tokens of staking
     */
    function withrawTokens() external {
        require(userBalance[msg.sender] > 0, "Insuficient Balance");
        require((block.timestamp - depositTime[msg.sender]) > stakingPeriod, "unfinished period");

        uint256 amountWithraw = userBalance[msg.sender];
        userBalance[msg.sender] = 0;

        bool success1 = IERC20(tokenpig).transfer(msg.sender, amountWithraw);
        require(success1);
        emit witrawTokens_(msg.sender, amountWithraw);
    }

    /**
     * @dev claim rewards
     */
    function claimRewards() external {
        require((block.timestamp - depositTime[msg.sender]) > stakingPeriod, "Time not ending");
        require(!rewardsHasClaim[msg.sender], "rewards has claim");

        rewardsHasClaim[msg.sender] = true;

        (bool success,) = msg.sender.call{value: rewards}("");
        require(success);

        emit claimRewards_(msg.sender, rewards);
    }

    /**
     * @dev set staking amount allow
     * @param newStakingAmount_ staking amount
     */
    function setStakingAmount(uint256 newStakingAmount_) external onlyOwner {
        fixedStakingAmount = newStakingAmount_;

        emit setStakingAmount_(msg.sender, newStakingAmount_);
    }

    /**
     * @dev set staking period
     * @param newStakingPeriod_ new staking period
     */
    function setStakingPeriod(uint256 newStakingPeriod_) external onlyOwner {
        stakingPeriod = newStakingPeriod_;

        emit setStakingPeriod_(msg.sender, newStakingPeriod_);
    }

    /**
     * @dev deposit ETH to pay rewards
     */
    receive() external payable {
        emit addFoundsForRewards_(msg.sender, msg.value);
    }
}

