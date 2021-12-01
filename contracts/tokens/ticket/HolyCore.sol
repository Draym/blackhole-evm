pragma solidity ^0.8.0;

import "../BuyableToken.sol";
import "../BurnableToken.sol";

// SPDX-License-Identifier: MIT
contract HolyCore is BuyableToken, BurnableToken {
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    constructor(uint256 _cost) ERC20("HolyCore", "CORE") {
        cost = _cost;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function craft(uint256 number) external onlyRole(FACTORY_ROLE) {
        _mint(msg.sender, number);
    }
}