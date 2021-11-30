pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./NokaiStats.sol";

// SPDX-License-Identifier: MIT
contract Nokai is ERC721Enumerable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    NokaiStats private nokaiStats;

    constructor(address _nokaiStats) ERC721("Nokai", "KAI") {
        nokaiStats = NokaiStats(_nokaiStats);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function generateNokai() external onlyRole(MINTER_ROLE) returns (uint256) {
        _tokenIds.increment();

        uint256 _newNokaiId = _tokenIds.current();
        _safeMint(msg.sender, _newNokaiId);

        nokaiStats.setupNokaiProfile(_newNokaiId);

        emit NokaiBorn(_newNokaiId, msg.sender);
        return _newNokaiId;
    }

    function absorb(uint256 nokaiId, uint256 targetId, NokaiStats.StatType upgradeChoice) external {
        require(ownerOf(nokaiId) == msg.sender, "you do not have ownership on this Nokai.");
        require(ownerOf(targetId) == msg.sender, "you do not have ownership on this target.");

        _burn(targetId);

        nokaiStats.upgradeFromNokaiBurn(nokaiId, targetId, upgradeChoice);

        emit NokaiUpgraded(nokaiId, msg.sender);
    }

    event NokaiBorn(uint256 indexed nokaiId, address indexed owner);
    event NokaiUpgraded(uint256 indexed nokaiId, address indexed owner);
}