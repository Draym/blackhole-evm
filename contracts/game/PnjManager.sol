pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./BlackHole.sol";

/**
 * Spawn PNJ in the map randomly through community events. If beaten player gains resources.
 */
// SPDX-License-Identifier: MIT
contract PnjManager is AccessControl {
    bytes32 public constant GENERATOR_ROLE = keccak256("GENERATOR_ROLE");
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _ids;

    struct Monster {
        uint256 position;
        // TODO define specs
    }

    // position holding a monster
    mapping(uint256 => uint256) private pos_to_monster;
    mapping(uint256 => Monster) private monsters;
    uint256 private totalMonsters;

    BlackHole private blackhole;

    constructor(address _blackhole)  {
        blackhole = BlackHole(_blackhole);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function generateMonsters(uint256 numbers) external onlyRole(GENERATOR_ROLE) {
        // TODO impl random generator
    }

    function monsterKilled(uint256 monsterId) external onlyRole(GAME_MANAGER_ROLE) {
        delete pos_to_monster[monsters[monsterId].position];
        delete monsters[monsterId];
    }

    function getMonsters() external view returns (Monster[] memory) {
        Monster[] memory _monsters = new Monster[](totalMonsters);
        for (uint256 i = 0; i < totalMonsters; i++) {
            _monsters[i] = monsters[i];
        }
        return _monsters;
    }

    function atPosition(uint16 x, uint16 y) external view returns (Monster memory) {
        return monsters[pos_to_monster[(y * x) + x]];
    }

    function byId(uint256 monsterId) external view returns (Monster memory) {
        return monsters[monsterId];
    }
}
