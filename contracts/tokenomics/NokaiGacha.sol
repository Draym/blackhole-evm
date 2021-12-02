pragma solidity ^0.8.0;

import "../character/Nokai.sol";
import "../tokens/ticket/HolyCore.sol";
import "../tokens/ticket/HolyArtefact.sol";

// SPDX-License-Identifier: MIT
contract NokaiGacha {
    Nokai private nokai;
    HolyCore private holyCore;
    HolyArtefact private holyArtefact;

    constructor(address _nokai, address _holyCore, address _holyArtefact) {
        nokai = Nokai(_nokai);
        holyCore = HolyCore(_holyCore);
        holyArtefact = HolyArtefact(_holyArtefact);
    }

    function openCore(uint256 _number) external returns (uint256[] memory) {
        require(_number <= 10, "gacha opener limited to 10 at once");
        require(holyCore.balanceOf(msg.sender) >= _number, "Insufficient number of HolyCore in your possession");
        holyCore.consume(msg.sender, _number);
        uint256[] memory ids = new uint256[](_number);
        for (uint256 i = 0; i < _number; i++) {
            ids[i] = nokai.generateNokai(false);
        }
        return ids;
    }

    function openArtefact(uint256 _number) external returns (uint256[] memory) {
        require(_number <= 10, "gacha opener limited to 10 at once");
        require(holyArtefact.balanceOf(msg.sender) >= _number, "Insufficient number of HolyArtefact in your possession");
        holyArtefact.consume(msg.sender, _number);
        uint256[] memory ids = new uint256[](_number);
        for (uint256 i = 0; i < _number; i++) {
            ids[i] = nokai.generateNokai(true);
        }
        return ids;
    }

    function available() external view returns (uint256) {
        return holyCore.balanceOf(msg.sender);
    }

    function availableSpecial() external view returns (uint256) {
        return holyArtefact.balanceOf(msg.sender);
    }
}
