pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/RandomUtils.sol";

// SPDX-License-Identifier: MIT
contract BlackHole is AccessControl {
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");

    string public name;
    uint16 public maxX;
    uint16 public maxY;
    uint256 public totalPos;

    struct Extractor {
        uint256 level;
        uint256 cost;
        uint256 lastExtract;
    }

    struct Territory {
        uint16 x;
        uint16 y;
        uint256 uxonium;
        uint256 darkMatter;
        uint256 plasmaEnergy;
        uint256 voidEssence;
        Extractor extractor; // extract resources
        uint256 nokai;
        address owner;
        bool discovered;
    }

    struct NokaiPos {
        bool onBoard;
        uint16 x;
        uint16 y;
    }

    mapping(address => uint256) private _userTerritoryCount;
    mapping(uint256 => Territory) private _blackhole;
    mapping(uint256 => NokaiPos) private _nokaiPosition;

    constructor(string memory _name, uint16 _width, uint16 _height)  {
        name = _name;
        maxX = _width;
        maxY = _height;
        totalPos = maxX * maxY;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _blackhole[((maxY / 2) * maxX) + maxX / 2] = Territory({
        x : maxX / 2,
        y : maxY / 2,
        uxonium : 10,
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
        require(_blackhole[pos].owner == by, "you are not the owner of the specified territory.");
        uint256 nbHours = (block.timestamp - _blackhole[pos].extractor.lastExtract) / 3600;
        _blackhole[pos].extractor.lastExtract = block.timestamp;
        uint256 _uxonium = _blackhole[pos].uxonium != 0 ? _blackhole[pos].uxonium * _blackhole[pos].extractor.level * nbHours : 0;
        uint256 _darkMatter = _blackhole[pos].darkMatter != 0 ? _blackhole[pos].darkMatter * _blackhole[pos].extractor.level * nbHours : 0;
        uint256 _plasmaEnergy = _blackhole[pos].plasmaEnergy != 0 ? _blackhole[pos].plasmaEnergy * _blackhole[pos].extractor.level * nbHours : 0;
        uint256 _voidEssence = _blackhole[pos].voidEssence != 0 ? _blackhole[pos].voidEssence * _blackhole[pos].extractor.level * nbHours : 0;
        emit TerritoryExtracted(x, y, by);
        return (_uxonium, _darkMatter, _plasmaEnergy, _voidEssence);
    }

    function upgradeExtractor(uint16 x, uint16 y, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 pos = (y * maxX) + x;
        require(_blackhole[pos].owner == by, "you are not the owner of the specified territory.");
        _blackhole[pos].extractor.level += 1;
        _blackhole[pos].extractor.cost *= 2;
        _blackhole[pos].extractor.lastExtract = block.timestamp;
        emit ExtractorUpgraded(x, y, by, _blackhole[pos].extractor.level);
    }


    function assignNokai(uint16 x, uint16 y, uint256 nokaiId, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 pos = (y * maxX) + x;
        if (_userTerritoryCount[by] > 0) {
            _assignNokai(pos, x, y, nokaiId, by);
        } else {
            _assignNokaiNewTerritory(pos, x, y, nokaiId);
        }
        emit NokaiAssigned(x, y, nokaiId, by);
    }

    function _assignNokaiNewTerritory(uint256 pos, uint16 x, uint16 y, uint256 nokaiId) private {
        require(_blackhole[pos].owner == address(0), "The specified territory is owned by another player.");
        require(_blackhole[pos].nokai == 0, "Specified territory is already occupied by a Nokai.");
        _blackhole[pos].nokai = nokaiId;
        _nokaiPosition[nokaiId].onBoard = true;
        _nokaiPosition[nokaiId].x = x;
        _nokaiPosition[nokaiId].y = y;
    }

    function _assignNokai(uint256 pos, uint16 x, uint16 y, uint256 nokaiId, address by) private {
        require(_blackhole[pos].owner == by, "You are not the owner of the specified territory.");
        require(_blackhole[pos].nokai == 0, "Specified territory is already occupied by a Nokai.");
        _blackhole[pos].nokai = nokaiId;
        _nokaiPosition[nokaiId].onBoard = true;
        _nokaiPosition[nokaiId].x = x;
        _nokaiPosition[nokaiId].y = y;
    }

    function withdrawDeadNokai(uint16 x, uint16 y, uint256 nokaiId) external onlyRole(GAME_MANAGER_ROLE) {
        _withdrawNokai((y * maxX) + x, nokaiId);
    }

    function withdrawNokai(uint16 x, uint16 y, uint256 nokaiId, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 pos = (y * maxX) + x;
        require(_blackhole[pos].owner == by, "You are not the owner of the specified territory.");
        require(_blackhole[pos].nokai == 1, "Specified territory is not occupied by a Nokai.");
        _withdrawNokai(pos, nokaiId);
    }

    function _withdrawNokai(uint256 pos, uint256 nokaiId) internal {
        require(_blackhole[pos].nokai == nokaiId, "Specified Nokai is not on specified territory.");
        _blackhole[pos].nokai = 0;
        delete _nokaiPosition[nokaiId];
        emit NokaiWithdrawn(nokaiId);
    }

    function conquest(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 from = (toY * maxX) + toX;
        uint256 to = (toY * maxX) + toX;
        require(_blackhole[from].owner == by, "You are not the owner of the original territory.");
        require(_blackhole[from].owner != _blackhole[to].owner, "Current and target territories are from the same owner.");
        require(_blackhole[to].nokai == 0, "Target territory is still defended by a Nokai.");
        require(_blackhole[from].nokai != 0, "Current territory does not have any Nokai to move.");

        address previousOwner = _blackhole[to].owner;

        _userTerritoryCount[previousOwner] = _userTerritoryCount[previousOwner] > 0 ? _userTerritoryCount[previousOwner] - 1 : 0;
        _userTerritoryCount[by] += 1;

        _blackhole[to].owner = by;
        _assignNokai(to, toX, toY, _blackhole[from].nokai, by);
        _blackhole[from].nokai = 0;

        _discover(toX, toY, _blackhole[from].owner);
        emit NokaiMoved(fromX, fromY, toX, toY, _blackhole[to].nokai, _blackhole[from].owner);
        emit SlotConquered(toX, toY, previousOwner, by);
    }

    function move(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, address by) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 from = (toY * maxX) + toX;
        uint256 to = (toY * maxX) + toX;
        require(_blackhole[from].owner == _blackhole[to].owner, "Current and target territories are not from the same owner.");
        require(_blackhole[from].nokai != 0, "Current territory does not have any Nokai to move.");

        _assignNokai(to, toX, toY, _blackhole[from].nokai, by);
        _blackhole[from].nokai = 0;

        _discover(toX, toY, _blackhole[from].owner);
        emit NokaiMoved(fromX, fromY, toX, toY, _blackhole[to].nokai, _blackhole[from].owner);
    }

    function _discover(uint16 x, uint16 y, address by) private {
        _discoverSlot(x - 1, y, by);
        _discoverSlot(x, y - 1, by);
        _discoverSlot(x + 1, y - 1, by);
        _discoverSlot(x + 1, y, by);
        _discoverSlot(x + 1, y + 1, by);
        _discoverSlot(x, y + 1, by);
    }

    function _discoverSlot(uint16 x, uint16 y, address by) private {
        uint256 pos = (y * maxX) + x;
        if (_blackhole[pos].discovered == false) {
            uint256 wealth = 10;
            if (wealth > totalPos / 4 && wealth < (totalPos / 4) * 3) {
                wealth = 40;
            }
            if (wealth > ((totalPos / 5) * 2) && wealth < (totalPos / 5) * 3) {
                wealth = 80;
            }
            uint256 darkMatter = RandomUtils._rand(pos, 100) + wealth;
            uint256 plasmaEnergy = RandomUtils._rand(pos + 1, 100) + wealth;
            uint256 voidEssence = RandomUtils._rand(pos + 2, 100) + wealth;
            if (darkMatter < plasmaEnergy || darkMatter < voidEssence) {
                darkMatter = 0;
            }
            if (plasmaEnergy < darkMatter || plasmaEnergy < voidEssence) {
                plasmaEnergy = 0;
            }
            if (voidEssence < darkMatter || voidEssence < plasmaEnergy) {
                voidEssence = 0;
            }
            _blackhole[pos] = Territory({
            x : x,
            y : y,
            uxonium : 0,
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

    function nokaiAt(uint16 x, uint16 y) external view returns (uint256) {
        return _blackhole[(y * maxX) + x].nokai;
    }

    function nokaiPos(uint256 nokaiId) external view returns (NokaiPos memory) {
        return _nokaiPosition[nokaiId];
    }

    function territoryCount(address user) external view returns (uint256) {
        return _userTerritoryCount[user];
    }

    function extractorCostAt(uint16 x, uint16 y) external view returns (uint256) {
        return _blackhole[(y * maxX) + x].extractor.cost;
    }

    function get(uint16 x, uint16 y) external view returns (Territory memory) {
        return _blackhole[(y * maxX) + x];
    }

    function getForRange(uint256 from, uint256 to) external view returns (Territory[] memory) {
        require(from >= 0 && to < totalPos, "invalid range request");
        Territory[] memory blackhole = new Territory[](to - from);
        for (uint256 i = from; i < to; i++) {
            blackhole[i] = _blackhole[i];
        }
        return blackhole;
    }

    function getFor(uint256[] calldata choices) external view returns (Territory[] memory) {
        Territory[] memory blackhole = new Territory[](choices.length);
        for (uint256 i = 0; i < choices.length; i++) {
            uint256 pos = choices[i];
            if (pos >= 0 && pos < totalPos) {
                blackhole[i] = _blackhole[pos];
            }
        }
        return blackhole;
    }

    function getForBox(uint256 startPos, uint256 endPos, uint256 startLine, uint256 endLine) external view returns (Territory[] memory) {
        require(startPos < endPos && startPos >= 0 && endPos <= maxX && startLine < endLine && startLine >= 0 && endLine <= maxY, "invalid box request");
        Territory[] memory blackhole = new Territory[]((endPos - startPos) * (endLine - startLine));
        uint256 i = 0;
        for (uint256 line = startLine; line < endLine; line++) {
            for (uint256 pos = startPos; pos < endPos; pos++) {
                blackhole[i++] = _blackhole[(line * maxX) + pos];
            }
        }
        return blackhole;
    }

    function getAvailableForBox(uint256 startPos, uint256 endPos, uint256 startLine, uint256 endLine) external view returns (uint256[] memory) {
        require(startPos < endPos && startPos >= 0 && endPos <= maxX && startLine < endLine && startLine >= 0 && endLine <= maxY, "invalid box request");
        uint256[] memory available = new uint256[]((endPos - startPos) * (endLine - startLine));
        uint256 i = 0;
        for (uint256 line = startLine; line < endLine; line++) {
            for (uint256 pos = startPos; pos < endPos; pos++) {
                if (_blackhole[(line * maxX) + pos].owner == address(0)) {
                    available[i++] = (line * maxX) + pos;
                }
            }
        }
        return available;
    }

    event SlotDiscovered(uint16 x, uint16 y, address by);
    event SlotConquered(uint16 x, uint16 y, address indexed previousOwner, address indexed newOwner);
    event NokaiAssigned(uint16 x, uint16 y, uint256 indexed nokai, address indexed owner);
    event NokaiWithdrawn(uint256 indexed nokai);
    event NokaiMoved(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, uint256 indexed nokai, address indexed owner);
    event TerritoryExtracted(uint16 x, uint16 y, address by);
    event ExtractorUpgraded(uint16 x, uint16 y, address by, uint256 level);
}