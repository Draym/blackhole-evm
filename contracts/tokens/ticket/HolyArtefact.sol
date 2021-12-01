pragma solidity ^0.8.0;

import "../BuyableToken.sol";
import "../BurnableToken.sol";

// SPDX-License-Identifier: MIT
contract HolyArtefact is BuyableToken, BurnableToken {
    constructor(uint256 _cost) ERC20("HolyArtefact", "GOD") {
        cost = _cost;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
