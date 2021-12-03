pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
contract NokaiTechnique {

    enum Technique {
        SPECIALIST, // hit twice at 75%
        GUARDIAN, // block 40% dmg after defense
        GLUTTON, // steal 30% opponent's attack stat
        BUFFOON, // reduce opponent's attack and defence by 20%
        DESTROYER, // break 50% opponent's defense
        FOOL, // cancel opponent's passives
        DEADLY, // critical hit - deal +40% dmg
        AUTHORITY, // survive with 1hp if killed by lower class Nokai
        REVENGER, // hit twice at 100% on death
        MIMIC // copy opponent technique
    }

    function get(uint256 _newNokaiId) external view returns (Technique) {
        return Technique(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _newNokaiId))) % 10);
    }
}
