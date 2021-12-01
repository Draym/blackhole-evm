pragma solidity ^0.8.0;

import "../tokens/Item.sol";
import "../character/Nokai.sol";

// SPDX-License-Identifier: MIT
contract Inventory {
    NokaiStats private nokaiStats;
    Item private potionEssence;
    Item private lifeEssence;
    Item private energyShock;

    uint256 healPerPotion = 100;
    uint256 paPerShock = 5;

    constructor(address _nokaiStats, address _potionEssence, address _lifeEssence, address _energyShock) {
        nokaiStats = NokaiStats(_nokaiStats);
        potionEssence = Item(_potionEssence);
        lifeEssence = Item(_lifeEssence);
        energyShock = Item(_energyShock);
    }

    function healNokai(uint256 nokaiId, uint256 amount) external {
        potionEssence.consume(msg.sender, amount);
        nokaiStats.heal(nokaiId, amount * healPerPotion);
    }

    function reviveNokai(uint256 nokaiId) external {
        lifeEssence.consume(msg.sender, 1);
        nokaiStats.reborn(nokaiId);
    }

    function energizeNokai(uint256 nokaiId, uint256 amount) external {
        energyShock.consume(msg.sender, amount);
        nokaiStats.energize(nokaiId, amount * paPerShock);
    }
}
