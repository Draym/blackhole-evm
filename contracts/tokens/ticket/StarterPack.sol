pragma solidity ^0.8.0;

import "../BuyableToken.sol";
import "../BurnableToken.sol";
import "../GiftableToken.sol";

// SPDX-License-Identifier: MIT
contract StarterPack is BuyableToken, BurnableToken, GiftableToken {
    constructor(uint256 cost) ERC20("StarterPack", "NEWBIE") {
        costPerUnit = cost;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(WITHDRAW_ROLE, msg.sender);
    }
}