pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// SPDX-License-Identifier: MIT
abstract contract Resource is ERC20, AccessControl {
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");
    bytes32 public constant CRAFT_MANAGER_ROLE = keccak256("CRAFT_MANAGER_ROLE");

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function collect(address user, uint256 amount) external virtual onlyRole(GAME_MANAGER_ROLE) {
        _mint(user, amount);
    }

    function consume(address user, uint256 amount) external virtual onlyRole(CRAFT_MANAGER_ROLE) {
        _burn(user, amount);
    }
}
