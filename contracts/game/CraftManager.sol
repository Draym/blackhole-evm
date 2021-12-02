pragma solidity ^0.8.0;

import "../tokens/ticket/HolyCore.sol";
import "../tokens/Item.sol";
import "../tokens/Resource.sol";
import "../tokens/ticket/HolyArtefact.sol";

// SPDX-License-Identifier: MIT
contract CraftManager {
    HolyCore private holyCore;
    HolyArtefact private holyArtefact;
    Item private potionEssence;
    Item private lifeEssence;
    Item private energyShock;
    Resource private darkEnergy;
    Resource private darkMatter;
    Resource private plasmaEnergy;
    Resource private voidEssence;

    constructor(address _holyCore, address _holyArtefact, address _potionEssence, address _lifeEssence, address _energyShock, address _darkEnergy, address _darkMatter, address _plasmaEnergy, address _voidEssence) {
        holyCore = HolyCore(_holyCore);
        holyArtefact = HolyArtefact(_holyArtefact);
        potionEssence = Item(_potionEssence);
        lifeEssence = Item(_lifeEssence);
        energyShock = Item(_energyShock);
        darkEnergy = Resource(_darkEnergy);
        darkMatter = Resource(_darkMatter);
        plasmaEnergy = Resource(_plasmaEnergy);
        voidEssence = Resource(_voidEssence);
    }

    function craftHolyCore(uint256 _number) external {

    }

    function craftHolyArtifact(uint256 _number) external {

    }

    function craftPotionEssence(uint256 _number) external {

    }

    function craftLifeEssence(uint256 _number) external {

    }

    function craftEnergyShock(uint256 _number) external {

    }
}