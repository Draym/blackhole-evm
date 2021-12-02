pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// SPDX-License-Identifier: MIT
abstract contract BurnableToken is ERC20, AccessControl {
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");

    function consume(address user, uint256 number) external onlyRole(BURN_ROLE) {
        require(balanceOf(user) >= number, "user do not own enough tokens");
         _burn(user, number);
    }
}
