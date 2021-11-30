pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
library  RandomUtils {
    function rand(uint256 _value, uint256 _modulo) internal view returns (uint256) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _value))) % _modulo;
    }
}
