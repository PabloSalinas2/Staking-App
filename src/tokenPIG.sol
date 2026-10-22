// LICENSE
//SPDX-License-Identifier: MIT

// VERSION SOLIDITY

pragma solidity 0.8.24;

// CONTRACT

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract TokenPIG is ERC20, Ownable {
    // variables

    // events
    event mintear(address acount, uint256 amount);
    event burn(uint256 amount);

    // modifiers

    // constructor
    // REVISAR SI ESTA BIEN PUESTO EL OWNER
    constructor(string memory name_, string memory symbol_, address owner_) ERC20(name_, symbol_) Ownable(owner_) {}

    // functions

    function mint(address to_, uint256 amount_) public onlyOwner {
        require(to_ != address(0), "to_ can not be address 0");

        _mint(to_, amount_);
        emit mintear(to_, amount_);
    }

    function burn_tokens(address from, uint256 amount_) public onlyOwner {
        _burn(from, amount_);
        emit burn(amount_);
    }
}

