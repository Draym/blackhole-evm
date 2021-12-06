pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./NokaiStats.sol";

// SPDX-License-Identifier: MIT
contract Nokai is ERC721Enumerable, AccessControl {
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    NokaiStats private nokaiStats;

    bool isSetup;
    bool mintLocked;
    bool transferLocked;
    string uri;

    constructor(address _nokaiStats, string memory baseUri) ERC721("Nokai", "KAI") {
        nokaiStats = NokaiStats(_nokaiStats);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        uri = baseUri;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function generateNokai(bool isRare) external onlyRole(MINT_ROLE) returns (uint256) {
        require(isSetup == true, "mint is not available yet.");
        require(mintLocked == false, "mint has been locked.");
        _tokenIds.increment();

        uint256 _newNokaiId = _tokenIds.current();
        _safeMint(msg.sender, _newNokaiId);

        if (isRare == true) {
            nokaiStats.generateHighNokai(_newNokaiId);
        } else {
            nokaiStats.generateNokai(_newNokaiId);
        }
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

    function setup(uint256 nbGods) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(isSetup == false, "setup already completed.");

        isSetup = true;
        for (uint256 i = 0; i < nbGods; i++) {
            _tokenIds.increment();
            uint256 _newNokaiId = _tokenIds.current();
            _safeMint(msg.sender, _newNokaiId);
            nokaiStats.generateGodNokai(_newNokaiId);
        }
    }

    function lockMint() external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintLocked = true;
    }

    function unlockMint() external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintLocked = true;
    }

    function lockTransfer() external onlyRole(DEFAULT_ADMIN_ROLE) {
        transferLocked = true;
    }

    function unlockTransfer() external onlyRole(DEFAULT_ADMIN_ROLE) {
        transferLocked = false;
    }

    function setUri(string calldata baseUri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uri = baseUri;
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(transferLocked == false, "transfer has been locked.");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    event NokaiBorn(uint256 indexed nokaiId, address indexed owner);
    event NokaiUpgraded(uint256 indexed nokaiId, address indexed owner);
}