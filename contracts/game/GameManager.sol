pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BlackHole.sol";
import "../tokens/Resource.sol";
import "../character/NokaiStats.sol";
import "../character/Nokai.sol";
import "./BattleLogic.sol";

/**
 * Handle game interaction (move, build, battle) direct api to use from Web. no roles
 * will use the manager of different functionalities and check that everything is allowed before execute an action
 */
// SPDX-License-Identifier: MIT
contract GameManager is Ownable {

    BlackHole private blackHole;
    Nokai private nokai;
    NokaiStats private nokaiStats;
    BattleLogic private battleLogic;
    Resource private darkEnergy;
    Resource private darkMatter;
    Resource private plasmaEnergy;
    Resource private voidEssence;

    constructor(address _blackHole, address _nokai, address _nokaiStats, address _battleLogic, address _darkEnergy, address _darkMatter, address _plasmaEnergy, address _voidEssence) {
        blackHole = BlackHole(_blackHole);
        nokai = Nokai(_nokai);
        nokaiStats = NokaiStats(_nokaiStats);
        battleLogic = BattleLogic(_battleLogic);
        darkEnergy = Resource(_darkEnergy);
        darkMatter = Resource(_darkMatter);
        plasmaEnergy = Resource(_plasmaEnergy);
        voidEssence = Resource(_voidEssence);
    }

    function migrateBattleLogic(address _battleLogic) external onlyOwner {
        battleLogic = BattleLogic(_battleLogic);
    }

    /**
     * Nokai Actions
     */
    function move(uint16 fromX, uint16 fromY, uint16 target) external {
        uint256 nokaiId = blackHole.nokaiAt(fromX, fromY);
        require(nokaiId != 0, "There is no Nokai on the selected territory.");
        require(nokai.ownerOf(nokaiId) == msg.sender, "Your are not the owner of the selected Nokai");
        (uint16 targetX, uint16 targetY) = getPos(fromX, fromY, target);
        blackHole.conquest(fromX, fromY, targetX, targetY, msg.sender);
    }

    function conquer(uint16 fromX, uint16 fromY, uint16 target) external {
        uint256 attackerId = blackHole.nokaiAt(fromX, fromY);
        require(attackerId != 0, "There is no Nokai on the selected territory.");
        require(nokai.ownerOf(attackerId) == msg.sender, "Your are not the owner of the selected Nokai");

        (uint16 targetX, uint16 targetY) = getPos(fromX, fromY, target);

        uint256 defenderId = blackHole.nokaiAt(targetX, targetY);
        require(attackerId != 0, "There is no Nokai on the target territory.");
        require(nokai.ownerOf(attackerId) != msg.sender, "Your are the owner of the target Nokai");

        (, uint256 attackerHp, uint256 defenderHp) = battleLogic.battle(nokaiStats.profile(attackerId), nokaiStats.profile(attackerId));

        nokaiStats.damage(attackerId, attackerHp);
        nokaiStats.damage(defenderId, defenderHp);

        blackHole.conquest(fromX, fromY, targetX, targetY, msg.sender);
    }

    function teleport(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY) external {
        uint256 nokaiId = blackHole.nokaiAt(fromX, fromY);
        require(nokaiId != 0, "There is no Nokai on the selected territory.");
        require(nokai.ownerOf(nokaiId) == msg.sender, "your are not the owner of the selected Nokai");
        nokaiStats.didAction(nokaiId);
        blackHole.move(fromX, fromY, toX, toY, msg.sender);
    }

    function getPos(uint16 fromX, uint16 fromY, uint16 target) internal pure returns (uint16, uint16) {
        if (target == 0) {
            return (fromX - 1, fromY);
        } else if (target == 1) {
            return (fromX, fromY - 1);
        } else if (target == 1) {
            return (fromX + 1, fromY - 1);
        } else if (target == 1) {
            return (fromX + 1, fromY);
        } else if (target == 1) {
            return (fromX + 1, fromY + 1);
        } else {
            return (fromX, fromY + 1);
        }
    }

    /**
     * Slot' Resource Actions
     */
    function upgradeExtractor(uint16 x, uint16 y) external {
        collectResources(x, y);
        uint256 cost = blackHole.extractorCostAt(x, y);
        darkMatter.consume(msg.sender, cost);
        plasmaEnergy.consume(msg.sender, cost / 2);
        blackHole.upgradeExtractor(x, y, msg.sender);
    }

    function collectResources(uint16 x, uint16 y) public {
        (uint256 _darkEnergy, uint256 _darkMatter, uint256 _plasmaEnergy, uint256 _voidEssence) = blackHole.completeExtraction(x, y, msg.sender);
        darkEnergy.collect(msg.sender, _darkEnergy);
        darkMatter.collect(msg.sender, _darkMatter);
        plasmaEnergy.collect(msg.sender, _plasmaEnergy);
        voidEssence.collect(msg.sender, _voidEssence);
    }
}
