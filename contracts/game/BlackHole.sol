pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../utils/RandomUtils.sol";

// SPDX-License-Identifier: MIT
contract BlackHole is AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");

    uint16 maxX;
    uint16 maxY;
    uint256 maxSlot;

    struct Slot {
        uint16 x;
        uint16 y;
        uint256 darkEnergy;
        uint256 darkMatter;
        uint256 plasmaEnergy;
        uint256 voidEssence;
        uint256 nokai;
        uint256 extractor; // extract resources
        address owner;
        bool discovered;
    }

    mapping(uint256 => Slot) private blackhole;

    constructor(uint16 _width, uint16 _height)  {
        maxX = _width;
        maxY = _height;
        maxSlot = maxX * maxY;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        blackhole[((maxY / 2) * maxX) + maxX / 2] = Slot({
        x : maxX / 2,
        y : maxY / 2,
        darkEnergy : 10,
        darkMatter : 0,
        plasmaEnergy : 0,
        voidEssence : 0,
        nokai : 0,
        extractor : 1,
        owner : address(0),
        discovered : true
        });
    }

    function conquestAfterBattle(uint16 x, uint16 y, address newOwner) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 pos = (y * maxX) + x;
        require(blackhole[pos].nokai == 0, "target slot is still defended by a Nokai.");
        address previousOwner = blackhole[pos].owner;

        emit SlotConquered(x, y, previousOwner, newOwner);
    }

    function conquestAfterMove(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, address newOwner) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 from = (toY * maxX) + toX;
        uint256 to = (toY * maxX) + toX;
        require(blackhole[from].owner != blackhole[to].owner, "current and target slot are from the same owner.");
        require(blackhole[to].nokai == 0, "target slot is still defended by a Nokai.");
        require(blackhole[from].nokai != 0, "current slot does not have any Nokai to move.");

        address previousOwner = blackhole[to].owner;

        blackhole[to].nokai = blackhole[from].nokai;
        blackhole[to].owner = newOwner;
        blackhole[from].nokai = 0;

        discover(toX, toY, blackhole[from].owner);
        emit NokaiMoved(fromX, fromY, toX, toY, blackhole[to].nokai, blackhole[from].owner);
        emit SlotConquered(toX, toY, previousOwner, newOwner);
    }

    function move(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY) external onlyRole(GAME_MANAGER_ROLE) {
        uint256 from = (toY * maxX) + toX;
        uint256 to = (toY * maxX) + toX;
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
        uint256 darkMatter = RandomUtils.rand(_position, 10);
        uint256 plasmaEnergy = RandomUtils.rand(_position + 1, 10);
        uint256 voidEssence = RandomUtils.rand(_position + 2, 10);
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
            blackhole[_position] = Slot({
            x : x,
            y : y,
            darkEnergy : 0,
            darkMatter : darkMatter,
            plasmaEnergy : plasmaEnergy,
            voidEssence : voidEssence / 10,
            nokai : 0,
            extractor : 0,
            owner : by,
            discovered : true
            });
            emit SlotDiscovered(x, y, by);
        }
    }

    function get(uint16 x, uint16 y) external view returns (Slot memory) {
        return blackhole[(y * maxX) + x];
    }

    function getBlackHole() external view returns (Slot[] memory) {
        uint256 max = maxY * maxX;
        Slot[] memory _blackhole = new Slot[](max);
        for (uint256 i = 0; i < max; i++) {
            _blackhole[i] = blackhole[i];
        }
        return _blackhole;
    }

    event SlotDiscovered(uint16 x, uint16 y, address by);
    event SlotConquered(uint16 x, uint16 y, address indexed previousOwner, address indexed newOwner);
    event NokaiMoved(uint16 fromX, uint16 fromY, uint16 toX, uint16 toY, uint256 indexed nokai, address indexed owner);
}