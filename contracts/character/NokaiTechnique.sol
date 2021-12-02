pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
contract NokaiTechnique {

    enum Technique {
        DOUBLE_HIT, // hit twice at 75%
        GUARDIAN, // block 50% dmg after defense
        GLUTTON, // heal for 30% dmg dealt
        TOXIC, // poison for 10% dmg dealt, stack infinite
        DESTROYER, // break 50% defense
        FOOL, // cancel opponent passives
        WEAK_POINT, // critical hit - deal +30% dmg
        SPEEDY, // always attack first
        REVENGER, // hit twice at 100% on death
        MIMIC // copy opponent technique
    }

    function get(uint256 _newNokaiId) external view returns (Technique) {
        return Technique(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _newNokaiId))) % 10);
    }
}
