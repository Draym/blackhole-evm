pragma solidity ^0.8.0;

import "../tokens/Item.sol";
import "../character/Nokai.sol";

// SPDX-License-Identifier: MIT
contract Inventory {
    NokaiStats private _nokaiStats;
    Item private _potionEssence;
    Item private _lifeEssence;
    Item private _energyShock;

    uint256 healPerPotion = 100;
    uint256 paPerShock = 5;

    constructor(address nokaiStats, address potionEssence, address lifeEssence, address energyShock) {
        _nokaiStats = NokaiStats(nokaiStats);
        _potionEssence = Item(potionEssence);
        _lifeEssence = Item(lifeEssence);
        _energyShock = Item(energyShock);
    }

    function healNokai(uint256 nokaiId, uint256 amount) external {
        _potionEssence.consume(msg.sender, amount);
        _nokaiStats.heal(nokaiId, amount * healPerPotion);
    }

    function reviveNokai(uint256 nokaiId) external {
        _lifeEssence.consume(msg.sender, 1);
        _nokaiStats.reborn(nokaiId);
    }

    function energizeNokai(uint256 nokaiId, uint256 amount) external {
        _energyShock.consume(msg.sender, amount);
        _nokaiStats.energize(nokaiId, amount * paPerShock);
    }
}
