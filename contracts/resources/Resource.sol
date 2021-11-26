pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// SPDX-License-Identifier: MIT
abstract contract Resource is ERC20, AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function deliver(uint256 _amount, address _user) external virtual onlyRole(MANUFACTURER_ROLE) {
        _mint(_user, _amount);
    }

    function consume(uint256 _amount, address _user) external virtual onlyRole(FACTORY_ROLE) {
        _burn(_user, _amount);
    }
}
