pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./BattleManager.sol";

/**
 * Handle game interaction (move, build, battle) direct api to use from Web. no roles
 * will use the manager of different functionalities and check that everything is allowed before execute an action
 */
// SPDX-License-Identifier: MIT
contract GameManager is Ownable {

    BattleManager private battleManager;

    constructor(address _battleManager) {
        battleManager = BattleManager(_battleManager);
    }

    function migrateBattleManager(address _battleManager) external onlyOwner {
        battleManager = BattleManager(_battleManager);
    }
}
