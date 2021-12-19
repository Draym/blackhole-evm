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

    BlackHole private _blackHole;
    Nokai private _nokai;
    NokaiStats private _nokaiStats;
    BattleLogic private _battleLogic;
    Resource private _uxonium;
    Resource private _darkMatter;
    Resource private _plasmaEnergy;
    Resource private _voidEssence;

    constructor(address blackHole, address nokai, address nokaiStats, address battleLogic, address uxonium, address darkMatter, address plasmaEnergy, address voidEssence) {
        _blackHole = BlackHole(blackHole);
        _nokai = Nokai(nokai);
        _nokaiStats = NokaiStats(nokaiStats);
        _battleLogic = BattleLogic(battleLogic);
        _uxonium = Resource(uxonium);
        _darkMatter = Resource(darkMatter);
        _plasmaEnergy = Resource(plasmaEnergy);
        _voidEssence = Resource(voidEssence);
    }

    function migrateBattleLogic(address battleLogic) external onlyOwner {
        _battleLogic = BattleLogic(battleLogic);
    }

    enum PositionTarget {
        TOP_LEFT,
        TOP_RIGHT,
        RIGHT,
        BOT_RIGHT,
        BOT_LEFT,
        LEFT
    }

    /**
     * Nokai Actions
     */
    function move(uint16 fromX, uint16 fromY, PositionTarget target) external {
        _verifyPos(fromX, fromY, _blackHole.maxX(), _blackHole.maxY());
        uint256 nokaiId = _blackHole.nokaiAt(fromX, fromY);
        require(nokaiId != 0, "There is no Nokai on the selected territory.");
        require(_nokai.ownerOf(nokaiId) == msg.sender, "Your are not the owner of the selected Nokai");
        (uint16 targetX, uint16 targetY) = _getPos(fromX, fromY, target);
        _verifyPos(targetX, targetY, _blackHole.maxX(), _blackHole.maxY());
        _nokaiStats.didAction(nokaiId, 1);
        _blackHole.conquest(fromX, fromY, targetX, targetY, msg.sender);
    }

    function conquer(uint16 fromX, uint16 fromY, uint16 target) external returns (uint256, bool) {
        _verifyPos(fromX, fromY, _blackHole.maxX(), _blackHole.maxY());
        uint256 attackerId = _blackHole.nokaiAt(fromX, fromY);
        require(attackerId != 0, "There is no Nokai on the selected territory.");
        require(_nokai.ownerOf(attackerId) == msg.sender, "Your are not the owner of the selected Nokai");

        (uint16 targetX, uint16 targetY) = _getPos(fromX, fromY, target);
        _verifyPos(targetX, targetY, _blackHole.maxX(), _blackHole.maxY());

        uint256 defenderId = _blackHole.nokaiAt(targetX, targetY);
        require(attackerId != 0, "There is no Nokai on the target territory.");
        require(_nokai.ownerOf(attackerId) != msg.sender, "Your are the owner of the target Nokai");

        (uint256 turns, uint256 attackerHp, uint256 defenderHp) = _battleLogic.battle(_nokaiStats.profile(attackerId), _nokaiStats.profile(attackerId));

        _nokaiStats.damage(attackerId, attackerHp);
        _nokaiStats.damage(defenderId, defenderHp);

        _nokaiStats.didAction(attackerId, 1);
        if (defenderHp == 0) {
            _blackHole.withdrawDeadNokai(targetX, targetY, defenderId);
            _blackHole.conquest(fromX, fromY, targetX, targetY, msg.sender);
        } else if (attackerHp == 0) {
            _blackHole.withdrawDeadNokai(fromX, fromY, attackerId);
        }
        return (turns, defenderHp == 0);
    }

    function teleport(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY) external {
        _verifyPos(fromX, fromY, _blackHole.maxX(), _blackHole.maxY());
        uint256 nokaiId = _blackHole.nokaiAt(fromX, fromY);
        _verifyPos(toX, toY, _blackHole.maxX(), _blackHole.maxY());
        require(nokaiId != 0, "There is no Nokai on the selected territory.");
        require(_nokai.ownerOf(nokaiId) == msg.sender, "your are not the owner of the selected Nokai");
        _nokaiStats.didAction(nokaiId, 5);
        _blackHole.move(fromX, fromY, toX, toY, msg.sender);
    }

    function assignNokaiToBoard(uint256 nokaiId, uint16 x, uint16 y) external {
        _verifyPos(x, y, _blackHole.maxX(), _blackHole.maxY());
        _blackHole.assignNokai(x, y, nokaiId, msg.sender);
    }

    function _verifyPos(uint16 x, uint16 y, uint16 maxX, uint16 maxY) internal pure {
        require(x >= 0, "position out of board");
        require(x < maxX, "position out of board");
        require(y >= 0, "position out of board");
        require(y < maxY, "position out of board");
    }

    function _getPos(uint16 fromX, uint16 fromY, PositionTarget target) internal pure returns (uint16, uint16) {
        if (target == PositionTarget.LEFT) {
            return (fromX - 1, fromY);
        } else if (target == PositionTarget.TOP_LEFT) {
            return (fromX - (fromY % 2 == 0 ? 1 : 0), fromY - 1);
        } else if (target == PositionTarget.TOP_RIGHT) {
            return (fromX + (fromY % 2 == 0 ? 0 : 1), fromY - 1);
        } else if (target == PositionTarget.RIGHT) {
            return (fromX + 1, fromY);
        } else if (target == PositionTarget.BOT_RIGHT) {
            return (fromX + (fromY % 2 == 0 ? 0 : 1), fromY + 1);
        } else {
            return (fromX - (fromY % 2 == 0 ? 1 : 0), fromY + 1);
        }
    }

    /**
     * Slot' Resource Actions
     */
    function upgradeExtractor(uint16 x, uint16 y) external {
        collectResources(x, y);
        uint256 cost = _blackHole.extractorCostAt(x, y);
        _darkMatter.consume(msg.sender, cost);
        _plasmaEnergy.consume(msg.sender, cost / 2);
        _blackHole.upgradeExtractor(x, y, msg.sender);
    }

    function collectResources(uint16 x, uint16 y) public {
        (uint256 uxonium, uint256 darkMatter, uint256 plasmaEnergy, uint256 voidEssence) = _blackHole.completeExtraction(x, y, msg.sender);
        _uxonium.collect(msg.sender, uxonium);
        _darkMatter.collect(msg.sender, darkMatter);
        _plasmaEnergy.collect(msg.sender, plasmaEnergy);
        _voidEssence.collect(msg.sender, voidEssence);
    }

    struct Pos {
        uint16 x;
        uint16 y;
    }

    function collectResourcesBash(Pos[] calldata positions) public {
        uint256 totalUxonium;
        uint256 totalDarkMatter;
        uint256 totalPlasmaEnergy;
        uint256 totalVoidEssence;

        for (uint256 i = 0; i < positions.length; i++) {
            (uint256 uxonium, uint256 darkMatter, uint256 plasmaEnergy, uint256 voidEssence) = _blackHole.completeExtraction(positions[i].x, positions[i].y, msg.sender);
            totalUxonium += uxonium;
            totalDarkMatter += darkMatter;
            totalPlasmaEnergy += plasmaEnergy;
            totalVoidEssence += voidEssence;
        }
        _uxonium.collect(msg.sender, totalUxonium);
        _darkMatter.collect(msg.sender, totalDarkMatter);
        _plasmaEnergy.collect(msg.sender, totalPlasmaEnergy);
        _voidEssence.collect(msg.sender, totalVoidEssence);
    }
}
