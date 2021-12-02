pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/RandomUtils.sol";

// SPDX-License-Identifier: MIT
contract BlackHole is AccessControl {
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");

    uint16 maxX;
    uint16 maxY;
    uint256 totalPos;

    struct Extractor {
        uint256 level;
        uint256 cost;
        uint256 lastExtract;
    }

    struct Territory {
        uint16 x;
        uint16 y;
        uint256 darkEnergy;
        uint256 darkMatter;
        uint256 plasmaEnergy;
        uint256 voidEssence;
        Extractor extractor; // extract resources
        uint256 nokai;
        address owner;
        bool discovered;
    }

    mapping(address => uint256) private userTerritoryCount;
    mapping(uint256 => Territory) private blackhole;

    constructor(uint16 _width, uint16 _height)  {
        maxX = _width;
        maxY = _height;
        totalPos = maxX * maxY;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        blackhole[((maxY / 2) * maxX) + maxX / 2] = Territory({
        x : maxX / 2,
        y : maxY / 2,
        darkEnergy : 10,
        darkMatter : 100,
        plasmaEnergy : 100,
        voidEssence : 100,
        extractor : Extractor({level : 1, cost : 1000, lastExtract : block.timestamp}),
        nokai : 0,
        owner : address(0),
        discovered : true
        });
    }

    function completeExtraction(uint16 x, uint16 y, address by) external onlyRole(GAME_MANAGER_ROLE) returns (uint256, uint256, uint256, uint256) {
        uint256 pos = (y * maxX) + x;
        require(blackhole[pos].owner == by, "you are not the owner of the specified territory.");
        uint256 nbHours = (block.timestamp - blackhole[pos].extractor.lastExtract) / 3600;
        blackhole[pos].extractor.lastExtract = block.timestamp;
        uint256 _darkEnergy = blackhole[pos].darkEnergy != 0 ? blackhole[pos].darkEnergy * blackhole[pos].extractor.level * nbHours : 0;
        uint256 _darkMatter = blackhole[pos].darkMatter != 0 ? blackhole[pos].darkMatter * blackhole[pos].extractor.level * nbHours : 0;
        uint256 _plasmaEnergy = blackhole[pos].plasmaEnergy != 0 ? blackhole[pos].plasmaEnergy * blackhole[pos].extractor.level * nbHours : 0;
        uint256 _voidEssence = blackhole[pos].voidEssence != 0 ? blackhole[pos].voidEssence * blackhole[pos].extractor.level * nbHours : 0;
        emit TerritoryExtracted(x, y, by);
        return (_darkEnergy, _darkMatter, _plasmaEnergy, _voidEssence);
    }

    function upgradeExtractor(uint16 x, uint16 y, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 pos = (y * maxX) + x;
        require(blackhole[pos].owner == by, "you are not the owner of the specified territory.");
        blackhole[pos].extractor.level += 1;
        blackhole[pos].extractor.cost *= 2;
        blackhole[pos].extractor.lastExtract = block.timestamp;
        emit ExtractorUpgraded(x, y, by, blackhole[pos].extractor.level);
    }

    function conquest(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 from = (toY * maxX) + toX;
        uint256 to = (toY * maxX) + toX;
        require(blackhole[from].owner == by, "You are not the owner of the original territory.");
        require(blackhole[from].owner != blackhole[to].owner, "current and target slot are from the same owner.");
        require(blackhole[to].nokai == 0, "target slot is still defended by a Nokai.");
        require(blackhole[from].nokai != 0, "current slot does not have any Nokai to move.");

        address previousOwner = blackhole[to].owner;

        userTerritoryCount[previousOwner] = userTerritoryCount[previousOwner] > 0 ? userTerritoryCount[previousOwner] - 1 : 0;
        userTerritoryCount[by] += 1;

        blackhole[to].nokai = blackhole[from].nokai;
        blackhole[to].owner = by;
        blackhole[from].nokai = 0;

        discover(toX, toY, blackhole[from].owner);
        emit NokaiMoved(fromX, fromY, toX, toY, blackhole[to].nokai, blackhole[from].owner);
        emit SlotConquered(toX, toY, previousOwner, by);
    }

    function move(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 from = (toY * maxX) + toX;
        uint256 to = (toY * maxX) + toX;
        require(blackhole[from].owner == by, "You are not the owner of the original territory.");
        require(blackhole[from].owner == blackhole[to].owner, "current and target slot are not from the same owner.");
        require(blackhole[from].nokai != 0, "current slot does not have any Nokai to move.");
        require(blackhole[to].nokai == 0, "target slot already host a Nokai.");

        blackhole[to].nokai = blackhole[from].nokai;
        blackhole[from].nokai = 0;

        discover(toX, toY, blackhole[from].owner);
        emit NokaiMoved(fromX, fromY, toX, toY, blackhole[to].nokai, blackhole[from].owner);
    }

    function discover(uint16 x, uint16 y, address by) private {
        discoverSlot(x - 1, y, by);
        discoverSlot(x, y - 1, by);
        discoverSlot(x + 1, y - 1, by);
        discoverSlot(x + 1, y, by);
        discoverSlot(x + 1, y + 1, by);
        discoverSlot(x, y + 1, by);
    }

    function discoverSlot(uint16 x, uint16 y, address by) private {
        uint256 _position = (y * maxX) + x;
        uint256 wealth = 10;
        if (wealth > totalPos / 4 && wealth < (totalPos / 4) * 3) {
            wealth = 20;
        }
        if (wealth > ((totalPos / 5) * 2) && wealth < (totalPos / 5) * 3) {
            wealth = 40;
        }
        uint256 darkMatter = RandomUtils.rand(_position, 100) + wealth;
        uint256 plasmaEnergy = RandomUtils.rand(_position + 1, 100) + wealth;
        uint256 voidEssence = RandomUtils.rand(_position + 2, 100) + wealth;
        if (darkMatter < plasmaEnergy || darkMatter < voidEssence) {
            darkMatter = 0;
        }
        if (plasmaEnergy < darkMatter || plasmaEnergy < voidEssence) {
            plasmaEnergy = 0;
        }
        if (voidEssence < darkMatter || voidEssence < plasmaEnergy) {
            voidEssence = 0;
        }
        if (blackhole[_position].discovered == false) {
            blackhole[_position] = Territory({
            x : x,
            y : y,
            darkEnergy : 0,
            darkMatter : darkMatter,
            plasmaEnergy : plasmaEnergy,
            voidEssence : voidEssence / 10,
            nokai : 0,
            extractor : Extractor({level : 0, cost : 500, lastExtract : block.timestamp}),
            owner : by,
            discovered : true
            });
            emit SlotDiscovered(x, y, by);
        }
    }

    function nokaiAt(uint16 x, uint16 y) external view returns(uint256) {
        return blackhole[(y * maxX) + x].nokai;
    }

    function territoryCount(address user) external view returns(uint256) {
        return userTerritoryCount[user];
    }

    function extractorCostAt(uint16 x, uint16 y) external view returns (uint256) {
        return blackhole[(y * maxX) + x].extractor.cost;
    }

    function get(uint16 x, uint16 y) external view returns (Territory memory) {
        return blackhole[(y * maxX) + x];
    }

    function getBlackHole() external view returns (Territory[] memory) {
        uint256 max = maxY * maxX;
        Territory[] memory _blackhole = new Territory[](max);
        for (uint256 i = 0; i < max; i++) {
            _blackhole[i] = blackhole[i];
        }
        return _blackhole;
    }

    event SlotDiscovered(uint16 x, uint16 y, address by);
    event SlotConquered(uint16 x, uint16 y, address indexed previousOwner, address indexed newOwner);
    event NokaiMoved(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, uint256 indexed nokai, address indexed owner);
    event TerritoryExtracted(uint16 x, uint16 y, address by);
    event ExtractorUpgraded(uint16 x, uint16 y, address by, uint256 level);
}