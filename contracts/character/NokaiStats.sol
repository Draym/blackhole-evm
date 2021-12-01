pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/RandomUtils.sol";
import "./NokaiTechnique.sol";

// SPDX-License-Identifier: MIT
contract NokaiStats is AccessControl {
    bytes32 public constant NOKAI_MANAGER_ROLE = keccak256("NOKAI_MANAGER_ROLE");
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");
    bytes32 public constant INVENTORY_MANAGER_ROLE = keccak256("INVENTORY_MANAGER_ROLE");

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
        uint256 currentHp;
        uint256 currentPa;
        bool dead;
        bool burned;
        uint256 lastHpSet;
        uint256 lastPaSet;
    }

    struct Stats {
        uint256 hp;
        uint256 attack;
        uint256 defense;
        uint256 regen;
        uint256 pa;
        uint256 gradeValue;
        Rarity grade;
        NokaiTechnique.Technique technique1;
        NokaiTechnique.Technique technique2;
    }

    NokaiTechnique private techniquePicker;
    mapping(uint256 => Profile) public profiles;

    constructor(address _techniquePicker) {
        techniquePicker = NokaiTechnique(_techniquePicker);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function generateNokai(uint256 newNokaiId) external onlyRole(NOKAI_MANAGER_ROLE) {
        saveNokaiProfile(
            newNokaiId,
            RandomUtils.rand(newNokaiId, 1000),
            RandomUtils.rand(newNokaiId + 1, 100) * 2,
            RandomUtils.rand(newNokaiId + 2, 100),
            RandomUtils.rand(newNokaiId + 3, 100),
            RandomUtils.rand(newNokaiId + 4, 10)
        );
    }

    function generateHighNokai(uint256 newNokaiId) external onlyRole(NOKAI_MANAGER_ROLE) {
        saveNokaiProfile(
            newNokaiId,
            RandomUtils.rand(newNokaiId, 1000) / 2 + 500,
            RandomUtils.rand(newNokaiId + 1, 100) + 100,
            RandomUtils.rand(newNokaiId + 2, 100) / 2 + 50,
            RandomUtils.rand(newNokaiId + 3, 100) / 2 + 50,
            5
        );
    }

    function generateLegendNokai(uint256 newNokaiId) external onlyRole(NOKAI_MANAGER_ROLE) {
        saveNokaiProfile(
            newNokaiId,
            RandomUtils.rand(newNokaiId, 100) + 900,
            RandomUtils.rand(newNokaiId + 1, 10) * 2 + 180,
            RandomUtils.rand(newNokaiId + 2, 10) + 90,
            RandomUtils.rand(newNokaiId + 3, 10) + 90,
            10
        );
    }

    function saveNokaiProfile(uint256 newNokaiId, uint256 hp, uint256 attack, uint256 defense, uint256 regen, uint256 _pa) private {
        uint256 pa = _pa;
        if (pa < 2) {
            pa = 2;
        } else if (pa > 8) {
            pa = 8;
        }
        Rarity grade = getBirthGrade(hp, attack, defense, regen, pa);

        profiles[newNokaiId] = Profile({
        stats : Stats({
        hp : hp,
        attack : attack,
        defense : defense,
        regen : regen,
        pa : pa,
        technique1 : techniquePicker.get(newNokaiId + 5),
        technique2 : techniquePicker.get(newNokaiId + 6),
        grade : grade,
        gradeValue : uint256(grade) + 1
        }),
        currentHp : hp,
        currentPa : pa,
        dead : false,
        burned : false,
        lastHpSet : block.timestamp,
        lastPaSet : block.timestamp
        });
    }

    function upgradeFromNokaiBurn(uint256 nokaiId, uint256 targetId, StatType upgradeChoice) external onlyRole(NOKAI_MANAGER_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[targetId].dead == false, "given target is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        require(profiles[targetId].burned == false, "given target is already burned.");
        require(profiles[nokaiId].stats.gradeValue >= profiles[targetId].stats.gradeValue, "target should be of a lower grade.");

        profiles[targetId].burned = true;

        if (upgradeChoice == StatType.HP) {
            profiles[nokaiId].stats.hp += profiles[targetId].stats.hp * profiles[targetId].stats.gradeValue / 100;
        } else if (upgradeChoice == StatType.ATTACK) {
            profiles[nokaiId].stats.attack += profiles[targetId].stats.attack * profiles[targetId].stats.gradeValue / 100;
        } else if (upgradeChoice == StatType.DEFENSE) {
            profiles[nokaiId].stats.defense += profiles[targetId].stats.defense * profiles[targetId].stats.gradeValue / 100;
        } else if (upgradeChoice == StatType.REGEN) {
            profiles[nokaiId].stats.regen += profiles[targetId].stats.regen * profiles[targetId].stats.gradeValue / 100;
        } else if (upgradeChoice == StatType.PA) {
            profiles[nokaiId].stats.pa += profiles[targetId].stats.gradeValue / 2;
        }
    }

    function getBirthGrade(uint256 hp, uint256 attack, uint256 defense, uint256 regen, uint256 pa) private pure returns (Rarity) {
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

    function damage(uint256 nokaiId, uint256 newHp) external onlyRole(GAME_MANAGER_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        profiles[nokaiId].lastHpSet = block.timestamp;
        if (newHp == 0) {
            profiles[nokaiId].currentHp = 0;
            profiles[nokaiId].dead = true;
            emit NokaiKilled(nokaiId);
        } else {
            profiles[nokaiId].currentHp = newHp;
            emit NokaiDamaged(nokaiId, newHp);
        }
    }

    function reborn(uint256 nokaiId) external onlyRole(INVENTORY_MANAGER_ROLE) {
        require(profiles[nokaiId].dead == true, "given Nokai is not dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        profiles[nokaiId].lastHpSet = block.timestamp;
        profiles[nokaiId].currentHp = profiles[nokaiId].stats.hp;
        profiles[nokaiId].dead = false;
        emit NokaiReborn(nokaiId);
    }

    function heal(uint256 nokaiId, uint256 amount) external onlyRole(INVENTORY_MANAGER_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        uint256 currentHp = calculateHp(nokaiId);
        profiles[nokaiId].lastHpSet = block.timestamp;
        if (currentHp + amount > profiles[nokaiId].stats.hp) {
            profiles[nokaiId].currentHp = profiles[nokaiId].stats.hp;
        } else {
            profiles[nokaiId].currentHp = currentHp + amount;
        }
        emit NokaiHealed(nokaiId, amount);
    }

    function energize(uint256 nokaiId, uint256 pa) external onlyRole(INVENTORY_MANAGER_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        uint256 currentPa = calculatePa(nokaiId);
        profiles[nokaiId].lastPaSet = block.timestamp;
        if (currentPa + pa > profiles[nokaiId].stats.pa) {
            profiles[nokaiId].currentPa = profiles[nokaiId].stats.pa;
        } else {
            profiles[nokaiId].currentPa = currentPa + pa;
        }
        emit NokaiEnergized(nokaiId);
    }

    function didAction(uint256 nokaiId) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 currentPa = calculatePa(nokaiId);
        profiles[nokaiId].lastPaSet = block.timestamp;
        if (currentPa - 1 <= 0) {
            profiles[nokaiId].currentPa = 0;
            emit NokaiEmptyEnergy(nokaiId);
        } else {
            profiles[nokaiId].currentPa = currentPa - 1;
        }
    }

    function calculateHp(uint256 nokaiId) internal view returns (uint256) {
        return profiles[nokaiId].currentHp + (profiles[nokaiId].stats.regen * ((block.timestamp - profiles[nokaiId].lastHpSet) / 3600));
    }

    function calculatePa(uint256 nokaiId) internal view returns (uint256) {
        return profiles[nokaiId].currentPa + ((block.timestamp - profiles[nokaiId].lastHpSet) / 7200);
    }

    function profile(uint256 nokaiId) external view returns (Profile memory) {
        return Profile({
        stats : profiles[nokaiId].stats,
        currentHp : calculateHp(nokaiId),
        currentPa : calculatePa(nokaiId),
        dead : profiles[nokaiId].dead,
        burned : profiles[nokaiId].burned,
        lastHpSet : profiles[nokaiId].lastHpSet,
        lastPaSet : profiles[nokaiId].lastPaSet
        });
    }

    event NokaiDamaged(uint256 indexed nokaiId, uint256 newHp);
    event NokaiKilled(uint256 indexed nokaiId);
    event NokaiReborn(uint256 indexed nokaiId);
    event NokaiHealed(uint256 indexed nokaiId, uint256 amount);
    event NokaiEnergized(uint256 indexed nokaiId);
    event NokaiEmptyEnergy(uint256 indexed nokaiId);
}
