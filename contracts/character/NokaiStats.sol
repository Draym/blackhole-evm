pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/RandomUtils.sol";
import "./NokaiTechnique.sol";

// SPDX-License-Identifier: MIT
contract NokaiStats is AccessControl {
    bytes32 public constant NOKAI_MANAGER_ROLE = keccak256("NOKAI_MANAGER_ROLE");
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
        uint32 hp;
        uint32 currentHp;
        uint32 attack;
        uint32 defense;
        uint32 regen;
        uint32 pa;
        uint32 currentPa;
        uint32 gradeValue;
        Rarity grade;
        NokaiTechnique.Technique technique;
        bool dead;
        bool burned;
    }

    NokaiTechnique private techniquePicker;
    mapping(uint256 => Profile) public profiles;

    constructor(address _techniquePicker) {
        techniquePicker = NokaiTechnique(_techniquePicker);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setupNokaiProfile(uint256 _newNokaiId) external onlyRole(NOKAI_MANAGER_ROLE) {
        uint32 hp = uint32(RandomUtils.rand(_newNokaiId, 1000));
        uint32 attack = uint32(RandomUtils.rand(_newNokaiId, 100) * 2);
        uint32 defense = uint32(RandomUtils.rand(_newNokaiId, 100));
        uint32 pa = uint32(RandomUtils.rand(_newNokaiId, 10));
        uint32 regen = uint32(RandomUtils.rand(_newNokaiId, 100));
        Rarity grade = getBirthGrade(hp, attack, defense, regen, pa);

        profiles[_newNokaiId] = Profile({
        hp : hp,
        currentHp : hp,
        attack : attack,
        defense : defense,
        regen : regen,
        pa : pa,
        currentPa : pa,
        technique : techniquePicker.get(_newNokaiId),
        grade : grade,
        gradeValue : uint32(grade) + 1,
        dead : false,
        burned : false
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
            profiles[nokaiId].hp += profiles[targetId].hp * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.ATTACK) {
            profiles[nokaiId].attack += profiles[targetId].attack * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.DEFENSE) {
            profiles[nokaiId].defense += profiles[targetId].defense * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.REGEN) {
            profiles[nokaiId].regen += profiles[targetId].regen * profiles[targetId].gradeValue / 100;
        } else if (upgradeChoice == StatType.PA) {
            profiles[nokaiId].pa += profiles[targetId].pa * profiles[targetId].gradeValue / 100;
        }
    }

    function getBirthGrade(uint32 _hp, uint32 _attack, uint32 _defense, uint32 _regen, uint32 _pa) private pure returns (Rarity) {
        uint256 _total = _hp + (_attack * 5) + (_defense * 10) + (_pa * 100) + (_regen * 10);
        // max should be 5000
        if (_total > 4900) {
            return Rarity.Legend;
        } else if (_total > 4200) {
            return Rarity.Astral;
        } else if (_total > 3300) {
            return Rarity.Overlord;
        } else if (_total > 1900) {
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
            emit NokaiKilled(nokaiId, msg.sender);
        } else {
            profiles[nokaiId].currentHp -= amount;
            emit NokaiDamaged(nokaiId, msg.sender, amount);
        }
    }

    function reborn(uint256 nokaiId) external onlyRole(INVENTORY_ROLE) {
        require(profiles[nokaiId].dead == true, "given Nokai is not dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        profiles[nokaiId].currentHp = profiles[nokaiId].hp;
        profiles[nokaiId].dead = false;
        emit NokaiReborn(nokaiId, msg.sender);
    }

    function heal(uint256 nokaiId, uint32 amount) external onlyRole(INVENTORY_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        if (profiles[nokaiId].currentHp + amount > profiles[nokaiId].hp) {
            profiles[nokaiId].currentHp = profiles[nokaiId].hp;
        } else {
            profiles[nokaiId].currentHp += amount;
        }
        emit NokaiHealed(nokaiId, msg.sender, amount);
    }

    function energize(uint256 nokaiId, uint32 pa) external onlyRole(INVENTORY_ROLE) {
        require(profiles[nokaiId].dead == false, "given Nokai is already dead.");
        require(profiles[nokaiId].burned == false, "given Nokai is already burned.");
        if (profiles[nokaiId].currentPa + pa > profiles[nokaiId].pa) {
            profiles[nokaiId].currentPa = profiles[nokaiId].pa;
        } else {
            profiles[nokaiId].currentPa += pa;
        }
        emit NokaiEnergized(nokaiId, msg.sender);
    }

    event NokaiDamaged(uint256 indexed nokaiId, address indexed owner, uint256 amount);
    event NokaiKilled(uint256 indexed nokaiId, address indexed owner);
    event NokaiReborn(uint256 indexed nokaiId, address indexed owner);
    event NokaiHealed(uint256 indexed nokaiId, address indexed owner, uint256 amount);
    event NokaiEnergized(uint256 indexed nokaiId, address indexed owner);
}
