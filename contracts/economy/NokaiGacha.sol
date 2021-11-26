pragma solidity ^0.8.0;

import "../character/Nokai.sol";
import "../resources/HolyCore.sol";

// SPDX-License-Identifier: MIT
contract NokaiGacha {

    Nokai private nokai;
    HolyCore private holyCore;

    constructor(address _nokai, address _holyCore) {
        nokai = Nokai(_nokai);
        holyCore = HolyCore(_holyCore);
    }

    function open(uint256 _number) external returns (uint256[] memory) {
        require(_number <= 10, "gacha opener limited to 10 at once");
        require(holyCore.balanceOf(msg.sender) >= _number, "Insufficient number of HolyCore in your possession");
        holyCore.consumeCore(_number);
        uint256[] memory ids = new uint256[](_number);
        for (uint256 i = 0; i < _number; i++) {
            ids[i] = nokai.generateNokai();
        }
        return ids;
    }

    function available() external view returns (uint256) {
        return holyCore.balanceOf(msg.sender);
    }
}
