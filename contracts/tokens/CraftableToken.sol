pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// SPDX-License-Identifier: MIT
abstract contract CraftableToken is ERC20, AccessControl {

    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    function craft(address user, uint256 number) external onlyRole(FACTORY_ROLE) {
        _mint(user, number);
    }
}
