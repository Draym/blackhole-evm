pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
library RandomUtils {
    function _rand(uint256 value, uint256 modulo) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, value))) % modulo;
    }

    function _rand16(uint256 value, uint256 modulo) internal view returns (uint16) {
        return uint16(_rand(value, modulo));
    }
}
