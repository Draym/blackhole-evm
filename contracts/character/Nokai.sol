pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./NokaiTechnique.sol";

// SPDX-License-Identifier: MIT
contract Nokai is ERC721Enumerable, AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BATTLE_MANAGER_ROLE = keccak256("BATTLE_MANAGER_ROLE");
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    enum Rarity {
        Spirit,
        Champion,
        Overlord,
        Astral,
        Legend
    }

    struct NokaiStats {
        uint32 hp;
        uint32 currentHp;
        uint32 attack;
        uint32 defense;
        uint32 regen;
        uint32 pa;
        uint32 currentPa;
        NokaiTechnique.Technique technique;
        Rarity grade;
    }

    NokaiTechnique private techniquePicker;
    mapping(uint256 => NokaiStats) public stats;

    constructor(address _techniquePicker) ERC721("Nokai", "KAI") {
        techniquePicker = NokaiTechnique(_techniquePicker);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function generateNokai() public onlyRole(MINTER_ROLE) returns (uint256) {
        _tokenIds.increment();

        uint256 _newNokaiId = _tokenIds.current();
        _safeMint(msg.sender, _newNokaiId);

        uint32 hp = uint32(rand(_newNokaiId, 1000));
        uint32 attack = uint32(rand(_newNokaiId, 100) * 2);
        uint32 defense = uint32(rand(_newNokaiId, 100));
        uint32 pa = uint32(rand(_newNokaiId, 10));
        uint32 regen = uint32(rand(_newNokaiId, 100));

        stats[_newNokaiId] = NokaiStats({
        hp : hp,
        currentHp : hp,
        attack : attack,
        defense : defense,
        regen : regen,
        pa : pa,
        currentPa : pa,
        technique : techniquePicker.get(_newNokaiId),
        grade : getBirthGrade(hp, attack, defense, regen, pa)
        });
        return _newNokaiId;
    }

    function rand(uint256 _newNokaiId, uint256 _modulo) private view returns (uint256) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _newNokaiId))) % _modulo;
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}