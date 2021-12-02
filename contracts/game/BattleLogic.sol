pragma solidity ^0.8.0;

import "../character/NokaiStats.sol";

// SPDX-License-Identifier: MIT
contract BattleLogic {

    function battle(NokaiStats.Profile memory attacker, NokaiStats.Profile memory defender) external pure returns (uint256, uint256, uint256) {
        uint256 attackerHp = attacker.currentHp;
        uint256 defenderHp = defender.currentHp;

        uint256 turns = 0;

        while (attackerHp > 0 || defenderHp > 0) {
            // TODO compute attack / defense using stats and techniques
        }

        return (turns, attackerHp >= 0 ? attackerHp : 0, defenderHp >= 0 ? defenderHp : 0);
    }
}
