pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
library RandomUtils {
    function rand256(uint256 _value, uint256 _modulo) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _value))) % _modulo;
    }

    function rand32(uint256 _value, uint256 _modulo) internal view returns (uint32) {
        return uint32(rand256(_value, _modulo));
    }

    function rand16(uint256 _value, uint256 _modulo) internal view returns (uint16) {
        return uint16(rand256(_value, _modulo));
    }
}
