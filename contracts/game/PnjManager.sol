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

    struct PNJ {
        uint256 position;
        // TODO define specs
    }

    // position holding a monster
    mapping(uint256 => uint256) private _pos_to_pnj;
    mapping(uint256 => PNJ) private _pnj;
    uint256 private _totalPnj;

    BlackHole private _blackhole;

    constructor(address blackhole)  {
        _blackhole = BlackHole(blackhole);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function generateMonsters(uint256 numbers) external onlyRole(GENERATOR_ROLE) {
        // TODO impl random generator
    }

    function monsterKilled(uint256 id) external onlyRole(GAME_MANAGER_ROLE) {
        delete _pos_to_pnj[_pnj[id].position];
        delete _pnj[id];
    }

    function getPNJs() external view returns (PNJ[] memory) {
        PNJ[] memory pnjs = new PNJ[](_totalPnj);
        for (uint256 i = 0; i < _totalPnj; i++) {
            pnjs[i] = _pnj[i];
        }
        return pnjs;
    }

    function atPosition(uint16 x, uint16 y) external view returns (PNJ memory) {
        return _pnj[_pos_to_pnj[(y * x) + x]];
    }

    function byId(uint256 id) external view returns (PNJ memory) {
        return _pnj[id];
    }
}
