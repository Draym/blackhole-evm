pragma solidity ^0.8.0;

import "../character/Nokai.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";


/**
  * Calculate a fight between 2 Nokai and adjust required stats (hp..) of NFT
  */
// SPDX-License-Identifier: MIT
contract BattleManager is AccessControl {
    bytes32 public constant GAME_MANAGER_ROLE = keccak256("GAME_MANAGER_ROLE");

    Nokai private nokai;

    constructor(address _nokai) {
        nokai = Nokai(_nokai);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function battle(address _1, address _2) external returns(address) {
        // check how many turn 1 needs to kill 2, same for 2, the one with less turn win -> apply damage
    }
}
