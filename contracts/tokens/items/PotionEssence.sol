pragma solidity ^0.8.0;

import "../Item.sol";

// SPDX-License-Identifier: MIT
contract PotionEssence is Item {
    constructor() Item("PotionEssence", "LIFE") {
    }
}
