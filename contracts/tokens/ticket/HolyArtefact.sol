pragma solidity ^0.8.0;

import "../BuyableToken.sol";
import "../BurnableToken.sol";
import "../GiftableToken.sol";
import "../CraftableToken.sol";

// SPDX-License-Identifier: MIT
contract HolyArtefact is BuyableToken, BurnableToken, CraftableToken, GiftableToken {
    constructor(uint256 cost) ERC20("HolyArtefact", "GOD") {
        costPerUnit = cost;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
