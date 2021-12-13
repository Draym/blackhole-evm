pragma solidity ^0.8.0;

import "../BuyableToken.sol";
import "../BurnableToken.sol";
import "../GiftableToken.sol";
import "../CraftableToken.sol";

// SPDX-License-Identifier: MIT
contract LegendCore is BuyableToken, BurnableToken, CraftableToken, GiftableToken {
    constructor(uint256 cost) ERC20("LegendCore", "LCORE") {
        costPerUnit = cost;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(WITHDRAW_ROLE, msg.sender);
    }
}
