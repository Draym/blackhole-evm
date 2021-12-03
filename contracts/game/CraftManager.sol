pragma solidity ^0.8.0;

import "../tokens/ticket/HolyCore.sol";
import "../tokens/Item.sol";
import "../tokens/Resource.sol";
import "../tokens/ticket/HolyArtefact.sol";
import "../character/CraftsmanProfile.sol";

// SPDX-License-Identifier: MIT
contract CraftManager {

    CraftsmanProfile private _craftsmanProfile;
    HolyCore private _holyCore;
    HolyArtefact private _holyArtefact;
    Item private _potionEssence;
    Item private _lifeEssence;
    Item private _energyShock;
    Resource private _darkEnergy;
    Resource private _darkMatter;
    Resource private _plasmaEnergy;
    Resource private _voidEssence;

    constructor(address craftsmanProfile, address holyCore, address holyArtefact, address potionEssence, address lifeEssence, address energyShock, address darkEnergy, address darkMatter, address plasmaEnergy, address voidEssence) {
        _craftsmanProfile = CraftsmanProfile(craftsmanProfile);
        _holyCore = HolyCore(holyCore);
        _holyArtefact = HolyArtefact(holyArtefact);
        _potionEssence = Item(potionEssence);
        _lifeEssence = Item(lifeEssence);
        _energyShock = Item(energyShock);
        _darkEnergy = Resource(darkEnergy);
        _darkMatter = Resource(darkMatter);
        _plasmaEnergy = Resource(plasmaEnergy);
        _voidEssence = Resource(voidEssence);
    }

    function craftHolyCore(uint256 number) external {
        require(_craftsmanProfile.getLevel(msg.sender) >= 6, "Higher craft level required.");
        _darkMatter.consume(msg.sender, 4000 * number);
        _plasmaEnergy.consume(msg.sender, 6000 * number);
        _voidEssence.consume(msg.sender, 10000 * number);
        _holyCore.craft(msg.sender, number);
        _craftsmanProfile.addExperience(20000 * number, msg.sender);
    }

    function craftHolyArtifact(uint256 number) external {
        require(_craftsmanProfile.getLevel(msg.sender) >= 9, "Higher craft level required.");
        _darkEnergy.consume(msg.sender, 66 * number);
        _darkMatter.consume(msg.sender, 10000 * number);
        _plasmaEnergy.consume(msg.sender, 20000 * number);
        _voidEssence.consume(msg.sender, 30000 * number);
        _holyArtefact.craft(msg.sender, number);
        _craftsmanProfile.addExperience(60066 * number, msg.sender);
    }

    function craftPotionEssence(uint256 number) external {
        _darkMatter.consume(msg.sender, 50 * number);
        _plasmaEnergy.consume(msg.sender, 200 * number);
        _voidEssence.consume(msg.sender, 200 * number);
        _potionEssence.craft(msg.sender, number);
        _craftsmanProfile.addExperience(450 * number, msg.sender);
    }

    function craftLifeEssence(uint256 number) external {
        require(_craftsmanProfile.getLevel(msg.sender) >= 3, "Higher craft level required.");
        _darkMatter.consume(msg.sender, 500 * number);
        _plasmaEnergy.consume(msg.sender, 1500 * number);
        _voidEssence.consume(msg.sender, 3000 * number);
        _lifeEssence.craft(msg.sender, number);
        _craftsmanProfile.addExperience(5000 * number, msg.sender);
    }

    function craftEnergyShock(uint256 number) external {
        require(_craftsmanProfile.getLevel(msg.sender) >= 2, "Higher craft level required.");
        _darkMatter.consume(msg.sender, 400 * number);
        _plasmaEnergy.consume(msg.sender, 1200 * number);
        _voidEssence.consume(msg.sender, 400 * number);
        _energyShock.craft(msg.sender, number);
        _craftsmanProfile.addExperience(2000 * number, msg.sender);
    }
}