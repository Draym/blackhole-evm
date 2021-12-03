pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

// SPDX-License-Identifier: MIT
contract CraftsmanProfile is AccessControl {
    bytes32 public constant CRAFT_MANAGER_ROLE = keccak256("CRAFT_MANAGER_ROLE");

    struct Stats {
        bool setup;
        uint256 level;
        uint256 experience;
        uint256 nextLevel;
    }

    mapping(address => Stats) private _stats;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addExperience(uint256 amount, address user) external onlyRole(CRAFT_MANAGER_ROLE) {
        if (!_stats[user].setup) {
            _stats[user] = Stats({
            setup : true,
            level : 1,
            experience : 0,
            nextLevel : 2000
            });
        }
        if (_stats[user].experience + amount >= _stats[user].nextLevel) {
            _stats[user].level += 1;
            _stats[user].experience = _stats[user].experience + amount - _stats[user].nextLevel;
        } else {
            _stats[user].experience += amount;
        }
    }

    function getLevel(address user) external view returns (uint256) {
        return _stats[user].level;
    }
}
