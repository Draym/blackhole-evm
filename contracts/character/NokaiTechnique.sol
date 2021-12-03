pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
contract NokaiTechnique {

    enum Technique {
        SPECIALIST, // hit twice at 75%
        GUARDIAN, // block 40% dmg after defense
        GLUTTON, // steal 30% opponent's attack stat
        BUFFOON, // reduce opponent's attack and defence by 30%
        DESTROYER, // break 50% opponent's defense
        FOOL, // cancel opponent's passives
        DEADLY, // critical hit - deal +40% dmg
        SPEEDY, // always attack first
        REVENGER, // hit twice at 100% on death
        MIMIC // copy opponent technique
    }

    function get(uint256 _newNokaiId) external view returns (Technique) {
        return Technique(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _newNokaiId))) % 10);
    }

    function specialist() external pure returns (uint256) {
        return 75;
    }
    function guardian() external pure returns (uint256) {
        return 40;
    }
    function glutton() external pure returns (uint256) {
        return 30;
    }
    function buffoon() external pure returns (uint256) {
        return 30;
    }
    function destroyer() external pure returns (uint256) {
        return 50;
    }
    function deadly() external pure returns (uint256) {
        return 40;
    }
    function revenger() external pure returns (uint256) {
        return 100;
    }
}
