pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: MIT
abstract contract GiftableToken is ERC20, Ownable {

    function gift(address user, uint256 number) external onlyOwner {
        _mint(user, number);
    }
}
