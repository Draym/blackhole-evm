pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/RandomUtils.sol";
import "./NokaiTechnique.sol";

// SPDX-License-Identifier: MIT
contract NokaiStats is AccessControl {
    bytes32 public constant NOKAI_MANAGER_ROLE = keccak256("NOKAI_MANAGER_ROLE");
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");
    bytes32 public constant BATTLE_MANAGER_ROLE = keccak256("BATTLE_MANAGER_ROLE");
    bytes32 public constant INVENTORY_ROLE = keccak256("INVENTORY_ROLE");

    enum Rarity {
        Spirit,
        Champion,
        Overlord,
        Astral,
        Legend
    }

    enum StatType {
        HP,
        ATTACK,
        DEFENSE,
        REGEN,
        PA
    }

    struct Profile {
        Stats stats;
        uint32 currentHp;
        uint32 currentPa;
        uint32 gradeValue;
        Rarity grade;
        NokaiTechnique.Technique technique1;
        NokaiTechnique.Technique technique2;
        bool dead;
        bool burned;
        uint256 lastAction;
    }

    struct Stats {
        uint32 hp;
        uint32 attack;
        uint32 defense;
        uint32 regen;
        uint32 pa;
    }

    NokaiTechnique private techniquePicker;
    mapping(uint256 => Profile) public profiles;

    constructor(address _techniquePicker) {
        techniquePicker = NokaiTechnique(_techniquePicker);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setupNokaiProfile(uint256 newNokaiId) external onlyRole(NOKAI_MANAGER_ROLE) {
        saveNokaiProfile(
            newNokaiId,
            RandomUtils.rand32(newNokaiId, 1000),
            RandomUtils.rand32(newNokaiId + 1, 100) * 2,
            RandomUtils.rand32(newNokaiId + 2, 100),
            RandomUtils.rand32(newNokaiId + 3, 100),
            RandomUtils.rand32(newNokaiId + 4, 10)
        );
    }

    function saveNokaiProfile(uint256 newNokaiId, uint32 hp, uint32 attack, uint32 defense, uint32 regen, uint32 pa) private {
        Rarity grade = getBirthGrade(hp, attack, defense, regen, pa);

        profiles[newNokaiId] = Profile({
        stats : Stats({hp : hp, attack : attack, defense : defense, regen : regen, pa : pa}),
        currentHp : hp,
        currentPa : pa,
        technique1 : techniquePicker.get(newNokaiId + 5),
        technique2 : techniquePicker.get(newNokaiId + 6),
        grade : grade,
        gradeValue : uint32(grade) + 1,
        dead : false,
        burned : false,
        lastAction : block.timestamp
        });
    }

    function upgradeFromNokaiBurn(uint256 nokaiId, uint256 targetId, StatType upgradeChoice) external onlyRole(NOKAI_MANAGER_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[targetId].dead == false, "given target is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        require(profiles[targetId].burned == false, "given target is already burned.");
        require(profiles[nokaiId].gradeValue >= profiles[targetId].gradeValue, "target should be of a lower grade.");

        profiles[targetId].burned = true;

        if (upgradeChoice == StatType.HP) {
            profiles[nokaiId].stats.hp += profiles[targetId].stats.hp * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.ATTACK) {
            profiles[nokaiId].stats.attack += profiles[targetId].stats.attack * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.DEFENSE) {
            profiles[nokaiId].stats.defense += profiles[targetId].stats.defense * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.REGEN) {
            profiles[nokaiId].stats.regen += profiles[targetId].stats.regen * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.PA) {
            profiles[nokaiId].stats.pa += profiles[targetId].gradeValue / 2;
        }
    }

    function getBirthGrade(uint32 hp, uint32 attack, uint32 defense, uint32 regen, uint32 pa) private pure returns (Rarity) {
        uint256 total = hp + (attack * 5) + (defense * 10) + (pa * 100) + (regen * 10);
        // max should be 5000
        if (total > 4900) {
            return Rarity.Legend;
        } else if (total > 4200) {
            return Rarity.Astral;
        } else if (total > 3300) {
            return Rarity.Overlord;
        } else if (total > 1900) {
            return Rarity.Champion;
        } else {
            return Rarity.Spirit;
        }
    }

    function migrateNokaiTechnique(address _techniquePicker) external onlyRole(DEFAULT_ADMIN_ROLE) {
        techniquePicker = NokaiTechnique(_techniquePicker);
    }

    function damage(uint256 nokaiId, uint32 amount) external onlyRole(BATTLE_MANAGER_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        if (profiles[nokaiId].currentHp - amount <= 0) {
            profiles[nokaiId].currentHp = 0;
            profiles[nokaiId].dead = true;
            emit NokaiKilled(nokaiId);
        } else {
            profiles[nokaiId].currentHp -= amount;
            emit NokaiDamaged(nokaiId, amount);
        }
    }

    function reborn(uint256 nokaiId) external onlyRole(INVENTORY_ROLE) {
        require(profiles[nokaiId].dead == true, "given Nokai is not dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        profiles[nokaiId].currentHp = profiles[nokaiId].stats.hp;
        profiles[nokaiId].dead = false;
        emit NokaiReborn(nokaiId);
    }

    function heal(uint256 nokaiId, uint32 amount) external onlyRole(INVENTORY_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        if (profiles[nokaiId].currentHp + amount > profiles[nokaiId].stats.hp) {
            profiles[nokaiId].currentHp = profiles[nokaiId].stats.hp;
        } else {
            profiles[nokaiId].currentHp += amount;
        }
        emit NokaiHealed(nokaiId, amount);
    }

    function energize(uint256 nokaiId, uint32 pa) external onlyRole(INVENTORY_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        if (profiles[nokaiId].currentPa + pa > profiles[nokaiId].stats.pa) {
            profiles[nokaiId].currentPa = profiles[nokaiId].stats.pa;
        } else {
            profiles[nokaiId].currentPa += pa;
        }
        emit NokaiEnergized(nokaiId);
    }

    function didAction(uint256 nokaiId) external onlyRole(GAME_MANAGER_ROLE) {
        if (profiles[nokaiId].currentPa - 1 <= 0) {
            profiles[nokaiId].currentPa = 0;
            emit NokaiEmptyEnergy(nokaiId);
        } else {
            profiles[nokaiId].currentPa -= 1;
        }
    }

    function getProfile(uint256 nokaiId) external view returns (Profile memory) {
        return profiles[nokaiId];
    }

    event NokaiDamaged(uint256 indexed nokaiId, uint256 amount);
    event NokaiKilled(uint256 indexed nokaiId);
    event NokaiReborn(uint256 indexed nokaiId);
    event NokaiHealed(uint256 indexed nokaiId, uint256 amount);
    event NokaiEnergized(uint256 indexed nokaiId);
    event NokaiEmptyEnergy(uint256 indexed nokaiId);
}
