// LICENSE

// SPDX-LicenSe-Identifier: MIT

// VERSION SOLIDITY 

pragma solidity 0.8.24;

// CONTRACT 

import "../lib/openzeppelin-contracts/lib/forge-std/src/Test.sol";
import "../src/StakingApp.sol";
import "../src/tokenPIG.sol";

contract testStakingApp is Test {
    // variables
    
    StakingApp  stakingApp;
    TokenPIG  token;
    address user1= vm.addr(2);

    // StakingApp parameters
    uint256  stakingPeriod=1 weeks;
    uint256 fixedStakingAmount=100;
    uint256 rewards= 1 ether;
    address admin= vm.addr(1);

    // TokenPig parameters
    string   name = "PigToken";
    string  symbol = "PIG";
  

    // events 


    // modifiers


    // setup
    
    function setUp() external {

        token= new TokenPIG(name, symbol, admin);

        stakingApp= new StakingApp( address (token),stakingPeriod, fixedStakingAmount, admin,rewards);


    }

    // functions 

    function testStakingTokenCorrectlyDeployed() external view {
        assert(address(token)!= address(0));
    }

    function testStakingAppCorrectlyDeployed() external view {
        assert(address(stakingApp)!= address(0));
    }



    function testNewStakingIncorrectAmount() external {

        vm.startPrank(user1);
        
        uint256 amount= 110;
        deal(address(token),user1,amount);
        vm.expectRevert("Incorrect amount");
        stakingApp.new_staking(amount);

        vm.stopPrank();

    }


    function testNewStakingCorrect() external {
       
        uint256 amount_= 100;
        
        vm.startPrank(admin);

        token.mint(user1, amount_);

        vm.stopPrank(); 


        vm.startPrank(user1);

        uint256 deposit=IERC20(token).balanceOf(user1);
        IERC20(token).approve(address(stakingApp),deposit);
        uint256 user1BalanceBefore2= stakingApp.userBalance(user1);
        stakingApp.new_staking(deposit);
        uint256 user1BalanceAfter2= stakingApp.userBalance(user1);

        assert(user1BalanceAfter2 - user1BalanceBefore2 == deposit );

        vm.stopPrank();
    }


    function testWithrawTokensWithoutBalance() external {

        vm.startPrank(user1);

        vm.warp(block.timestamp +2 weeks);
        vm.expectRevert("Insuficient Balance");
        stakingApp.withrawTokens();

        vm.stopPrank();
        
    }


    function testWithrawTokensBeforeStakingPeriod() external {
        uint256 amount_= 100;
        
        vm.startPrank(admin);

        token.mint(user1, amount_);

        vm.stopPrank(); 


        vm.startPrank(user1);

        uint256 deposit=IERC20(token).balanceOf(user1);
        IERC20(token).approve(address(stakingApp),deposit);
        uint256 user1BalanceBefore2= stakingApp.userBalance(user1);
        stakingApp.new_staking(deposit);
        uint256 user1BalanceAfter2= stakingApp.userBalance(user1);

        assert(user1BalanceAfter2 - user1BalanceBefore2 == deposit );

        vm.stopPrank();


        vm.startPrank(user1);

        vm.expectRevert("unfinished period");
        stakingApp.withrawTokens();

        vm.stopPrank();

            
    }

    function testWithrawTokensCorrectly() external {
        uint256 amount_= 100;
        
        vm.startPrank(admin);

        token.mint(user1, amount_);

        vm.stopPrank(); 


        vm.startPrank(user1);

        uint256 deposit=IERC20(token).balanceOf(user1);
        IERC20(token).approve(address(stakingApp),deposit);
        uint256 user1BalanceBefore2= stakingApp.userBalance(user1);
        stakingApp.new_staking(deposit);
        uint256 user1BalanceAfter2= stakingApp.userBalance(user1);

        assert(user1BalanceAfter2 - user1BalanceBefore2 == deposit );

       


       

        
        uint256 balanceBefore= stakingApp.userBalance(user1);
        vm.warp(block.timestamp + 2 weeks);
        stakingApp.withrawTokens();
        uint256 balanceAfter= stakingApp.userBalance(user1);

        assert(balanceBefore== amount_);
        assert(balanceAfter==0);
        
        vm.stopPrank();
       
    }



    function testMoreThanOneStaking() external {

        vm.startPrank(user1);
        
        uint256 amount_balance= 200;
        deal(address(token),user1,amount_balance);
        
        uint256 amount_deposit= 100;
        IERC20(token).approve(address(stakingApp),amount_deposit);
        stakingApp.new_staking(amount_deposit);


        
        IERC20(token).approve(address(stakingApp),amount_deposit);
        vm.expectRevert("Staking limit exceeded");
        stakingApp.new_staking(amount_deposit);



        vm.stopPrank();
    }


    function testClaimRewardsBeforEndPeriod() external{
        
    
        vm.startPrank(admin);
        uint256 amount_= 100;

        token.mint(user1, amount_);

        vm.stopPrank(); 

        vm.startPrank(user1);
        uint256 deposit=IERC20(token).balanceOf(user1);

        uint256 user1BalanceBefore2= stakingApp.userBalance(user1);
        IERC20(token).approve(address(stakingApp),deposit);
        stakingApp.new_staking(deposit);
        uint256 user1BalanceAfter2= stakingApp.userBalance(user1);

        assert(user1BalanceAfter2 - user1BalanceBefore2 == deposit );

        vm.expectRevert("Time not ending");
        stakingApp.claimRewards();

        vm.stopPrank();


    }


    function testClaimCorrectly() external {

        vm.deal(address(stakingApp),3 ether);

        vm.startPrank(admin);

        uint256 amount_= 100;
        token.mint(user1, amount_);

        vm.stopPrank(); 


        vm.startPrank(user1);
        uint256 deposit=IERC20(token).balanceOf(user1);

        uint256 user1BalanceBefore2= stakingApp.userBalance(user1);
        IERC20(token).approve(address(stakingApp),deposit);
        stakingApp.new_staking(deposit);
        uint256 user1BalanceAfter2= stakingApp.userBalance(user1);

        assert(user1BalanceAfter2 - user1BalanceBefore2 == deposit );

        vm.warp(block.timestamp + 2 weeks);
        bool rewardsHasClaimBefore=stakingApp.rewardsHasClaim(user1);
        stakingApp.claimRewards();
        bool rewardsHasClaimAfter= stakingApp.rewardsHasClaim(user1);

        
        assert(!rewardsHasClaimBefore && rewardsHasClaimAfter);

        vm.stopPrank();
    }


    function testClaimRewardsMoreThanOnce() external {
        vm.deal(address(stakingApp),3 ether);

        vm.startPrank(admin);

        uint256 amount_= 100;
        token.mint(user1, amount_);

        vm.stopPrank(); 


        vm.startPrank(user1);
        uint256 deposit=IERC20(token).balanceOf(user1);

        uint256 user1BalanceBefore2= stakingApp.userBalance(user1);
        IERC20(token).approve(address(stakingApp),deposit);
        stakingApp.new_staking(deposit);
        uint256 user1BalanceAfter2= stakingApp.userBalance(user1);

        assert(user1BalanceAfter2 - user1BalanceBefore2 == deposit );

        vm.warp(block.timestamp + 2 weeks);
        bool rewardsHasClaimBefore=stakingApp.rewardsHasClaim(user1);
        stakingApp.claimRewards();
        bool rewardsHasClaimAfter= stakingApp.rewardsHasClaim(user1);

        
        assert(!rewardsHasClaimBefore && rewardsHasClaimAfter);

        vm.expectRevert("rewards has claim");
        stakingApp.claimRewards();

        vm.stopPrank();
    }


    function testDepositETH() external {
        uint256 amount_deposit= 4 ether;
        vm.deal(admin, amount_deposit);
        vm.startPrank(admin);
        
        (bool success,)=address(stakingApp).call{value:amount_deposit}("");
        require(success);

        assert(address(stakingApp).balance== amount_deposit);


        vm.stopPrank();
    }



    function testSetStakingAmountRandomUser() external{
        
        vm.startPrank(user1);

        uint256 newAmount= 200;
        vm.expectRevert();
        stakingApp.setStakingAmount(newAmount);

        vm.stopPrank();
    }

    
    function testSetStakingAmountAdmin() external{
        vm.startPrank(admin);

        uint256 newAmount= 200;
        
        uint256 fixedStakingAmountBefore=stakingApp.fixedStakingAmount();
        stakingApp.setStakingAmount(newAmount);
        uint256 fixedStakingAmountAfter=stakingApp.fixedStakingAmount();

        assert(fixedStakingAmountAfter + fixedStakingAmountBefore  ==newAmount + fixedStakingAmountBefore);

        vm.stopPrank();
    }


    function testSetStakingPeriodUserRandom() external {
        
        vm.startPrank(user1);

        uint256 newStakingPeriod = 200000000;
        vm.expectRevert();
        stakingApp.setStakingPeriod(newStakingPeriod);


        vm.stopPrank();
    }



    function testSetStakingPeriodAdmin() external {
        
        vm.startPrank(admin);

        uint256 newStakingPeriod = 200000000;
       
        uint256 stakingPeriodBefore= stakingApp.stakingPeriod();
        stakingApp.setStakingPeriod(newStakingPeriod);
        uint256 stakingPeriodAfter= stakingApp.stakingPeriod();

        assert(stakingPeriodAfter + stakingPeriodBefore == stakingPeriodBefore + newStakingPeriod );

        vm.stopPrank();
    }


}