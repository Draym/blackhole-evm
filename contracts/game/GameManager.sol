pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BlackHole.sol";
import "../tokens/Resource.sol";

/**
 * Handle game interaction (move, build, battle) direct api to use from Web. no roles
 * will use the manager of different functionalities and check that everything is allowed before execute an action
 */
// SPDX-License-Identifier: MIT
contract GameManager is Ownable {

    BlackHole private blackHole;
    Resource private darkEnergy;
    Resource private darkMatter;
    Resource private plasmaEnergy;
    Resource private voidEssence;

    constructor(address _blackHole, address _darkEnergy, address _darkMatter, address _plasmaEnergy, address _voidEssence) {
        blackHole = BlackHole(_blackHole);
        darkEnergy = Resource(_darkEnergy);
        darkMatter = Resource(_darkMatter);
        plasmaEnergy = Resource(_plasmaEnergy);
        voidEssence = Resource(_voidEssence);
    }

    /**
     * Nokai Actions
     */
    function move(uint256 nokaiId, uint16 x, uint16 y) external {

    }

    function conquer(uint256 nokaiId, uint16 x, uint16 y) external {

    }

    function teleport(uint256 nokaiId, uint16 x, uint16 y) external {

    }
    /**
     * Slot' Resource Actions
     */
    function upgradeExtractor(uint16 x, uint16 y) external {

    }

    function collectResources(uint16 x, uint16 y) external {

    }
}
