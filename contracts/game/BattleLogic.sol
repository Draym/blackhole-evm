pragma solidity ^0.8.0;

import "../character/NokaiStats.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// SPDX-License-Identifier: MIT
contract BattleLogic {

    uint256 constant _specialist = 75;
    uint256 constant _guardian = 40;
    uint256 constant _glutton = 30;
    uint256 constant _buffoon = 20;
    uint256 constant _destroyer = 50;
    uint256 constant _deadly = 40;
    uint256 constant _authority = 1;
    uint256 constant _revenger = 100;

    function battle(NokaiStats.Profile memory attacker, NokaiStats.Profile memory defender) external pure returns (uint256, uint256, uint256) {
        uint256 attackerHp = attacker.currentHp;
        uint256 defenderHp = defender.currentHp;

        uint256 attackerDPS = _calculateDPS(attacker, defender);
        uint256 defenderDPS = _calculateDPS(defender, attacker);

        uint256 attackerTurns = defenderHp / attackerDPS;
        uint256 defenderTurns = attackerHp / defenderDPS;

        if (attackerTurns <= defenderTurns) {
            defenderHp = 0;
            if (hasTechnique(defender, NokaiTechnique.Technique.REVENGER)) {
                attackerHp = minus(attackerHp, (attackerTurns * defenderDPS) + ((_revenger * defenderDPS / 100) * 2));
            } else {
                attackerHp = minus(attackerHp, attackerTurns * defenderDPS);
            }
        } else {
            attackerHp = 0;
            if (hasTechnique(attacker, NokaiTechnique.Technique.REVENGER)) {
                defenderHp = minus(defenderHp, defenderTurns * attackerDPS) + ((_revenger * attackerDPS / 100) * 2);
            } else {
                defenderHp = minus(defenderHp, defenderTurns * attackerDPS);
            }
        }

        if (attackerHp == 0 && attacker.stats.gradeValue > defender.stats.gradeValue && hasTechnique(attacker, NokaiTechnique.Technique.AUTHORITY)) {
            attackerHp = _authority;
        }
        if (defenderHp == 0 && defender.stats.gradeValue > attacker.stats.gradeValue && hasTechnique(defender, NokaiTechnique.Technique.AUTHORITY)) {
            defenderHp = _authority;
        }

        return (attackerTurns > defenderTurns ? defenderTurns : attackerTurns, attackerHp, defenderHp);
    }

    function _calculateDPS(NokaiStats.Profile memory nokai, NokaiStats.Profile memory opponent) internal pure returns (uint256) {
        uint256 nokaiAttack = nokai.stats.attack;
        uint256 opponentAttack = opponent.stats.attack;
        uint256 opponentDefense = opponent.stats.defense;
        uint256 output = 100;

        // apply MALUS
        if (missTechnique(nokai, NokaiTechnique.Technique.FOOL)) {
            if (hasTechnique(opponent, NokaiTechnique.Technique.GUARDIAN)) {
                output = minus(output, _guardian);
            }
            if (hasTechnique(opponent, NokaiTechnique.Technique.BUFFOON)) {
                nokaiAttack = reduce(nokaiAttack, _buffoon);
            }
        }
        // apply BONUS
        if (missTechnique(opponent, NokaiTechnique.Technique.FOOL)) {

            if (hasTechnique(nokai, NokaiTechnique.Technique.GLUTTON)) {
                nokaiAttack += percent(opponentAttack, _glutton);
            }
            if (hasTechnique(nokai, NokaiTechnique.Technique.BUFFOON)) {
                opponentDefense = reduce(opponentDefense, _buffoon);
            }
            if (hasTechnique(nokai, NokaiTechnique.Technique.DESTROYER)) {
                opponentDefense = reduce(opponentDefense, _destroyer);
            }
            if (hasTechnique(nokai, NokaiTechnique.Technique.DEADLY)) {
                nokaiAttack += percent(nokaiAttack, _deadly);
            }
        }

        if (hasTechnique(nokai, NokaiTechnique.Technique.SPECIALIST) && missTechnique(opponent, NokaiTechnique.Technique.FOOL)) {
            output -= _guardian;
            return Math.max(percent(minus(percent(nokaiAttack, _specialist), opponentDefense) * 2, output), 1);
        } else {
            return Math.max(percent(minus(nokaiAttack, opponentDefense), output), 1);
        }
    }

    function hasTechnique(NokaiStats.Profile memory nokai, NokaiTechnique.Technique technique) internal pure returns (bool) {
        return nokai.stats.technique1 == technique || nokai.stats.technique2 == technique;
    }

    function missTechnique(NokaiStats.Profile memory nokai, NokaiTechnique.Technique technique) internal pure returns (bool) {
        return nokai.stats.technique1 != technique && nokai.stats.technique2 != technique;
    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b >= a) return 0;
        return a - b;
    }

    function percent(uint256 v, uint256 p) internal pure returns (uint256) {
        return v * p / 100;
    }

    function reduce(uint256 v, uint256 p) internal pure returns (uint256) {
        return minus(v, v * p / 100);
    }
}
