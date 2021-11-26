pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
contract NokaiTechnique {

    constructor(){}

    enum Technique {
        DoubleHit,
        TO_DEFINE1,
        TO_DEFINE2,
        TO_DEFINE3,
        TO_DEFINE4,
        TO_DEFINE5,
        TO_DEFINE6,
        TO_DEFINE7,
        TO_DEFINE8,
        TO_DEFINE9
    }

    function get(uint256 _newNokaiId) external view returns (Technique) {
        return Technique(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _newNokaiId))) % 10);
    }
}
