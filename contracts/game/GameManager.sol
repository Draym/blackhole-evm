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
