// LICENSE

//SPDS-License-Identifier: MIT

// VERSION SOLIDITY

pragma solidity 0.8.24;

// CONTRACT

import "../lib/openzeppelin-contracts/lib/forge-std/src/Test.sol";
import "../src/tokenPIG.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract testTokenPIG is Test {
    // variables
    TokenPIG tokenPIG;
    address randomUser;
    address admin;

    // events

    // modifiers

    // setup
    function setUp() external {
        randomUser = vm.addr(1);
        admin = vm.addr(2);
        tokenPIG = new TokenPIG("tokenPig", "PIG", admin);
    }

    // functions

    function testMintNotOwner() external {
        address to_ = randomUser;
        uint256 amount_ = 1000;

        vm.startPrank(randomUser);

        vm.expectRevert();
        tokenPIG.mint(to_, amount_);

        vm.stopPrank();
    }

    function testMintAddress0() external {
        address to = address(0);
        uint256 amount = 10000000;
        vm.expectRevert();
        tokenPIG.mint(to, amount);
    }

    function testMintCorrectly() external {
        address to_ = randomUser;
        uint256 amount_ = 1000;

        vm.startPrank(admin);
        uint256 supplyBefore = IERC20(tokenPIG).totalSupply();
        tokenPIG.mint(to_, amount_);
        uint256 supplyAfter = IERC20(tokenPIG).totalSupply();

        assert(supplyAfter - supplyBefore == amount_);
        vm.stopPrank();
    }

    function testBurnNotOwner() external {
        address to_ = randomUser;
        uint256 amount_ = 1000;

        vm.startPrank(admin);
        uint256 supplyBefore = IERC20(tokenPIG).totalSupply();
        tokenPIG.mint(to_, amount_);
        uint256 supplyAfter = IERC20(tokenPIG).totalSupply();

        assert(supplyAfter - supplyBefore == amount_);
        vm.stopPrank();

        address from = randomUser;
        uint256 amount_burn = 10000;

        vm.startPrank(randomUser);

        vm.expectRevert();
        tokenPIG.burn_tokens(from, amount_burn);

        vm.stopPrank();
    }

    function testBurnTokensCorrectly() external {
        address to_ = randomUser;
        uint256 amount_ = 100000;

        vm.startPrank(admin);
        uint256 supplyBefore = IERC20(tokenPIG).totalSupply();
        tokenPIG.mint(to_, amount_);
        uint256 supplyAfter = IERC20(tokenPIG).totalSupply();

        assert(supplyAfter - supplyBefore == amount_);
        vm.stopPrank();

        address from = randomUser;
        uint256 amount_burn = 10000;

        vm.startPrank(admin);

        uint256 supplyBefore2 = IERC20(tokenPIG).totalSupply();
        tokenPIG.burn_tokens(from, amount_burn);
        uint256 supplyAfter2 = IERC20(tokenPIG).totalSupply();

        assert(supplyBefore2 - amount_burn == supplyAfter2);
        vm.stopPrank();
    }
}
