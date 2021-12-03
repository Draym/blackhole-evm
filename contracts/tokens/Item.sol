pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// SPDX-License-Identifier: MIT
contract Item is ERC20, AccessControl {
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function craft(address user, uint256 amount) external virtual onlyRole(MINT_ROLE) {
        _mint(user, amount);
    }

    function consume(address user, uint256 amount) external virtual onlyRole(BURN_ROLE) {
        _burn(user, amount);
    }
}