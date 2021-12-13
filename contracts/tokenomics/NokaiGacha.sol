pragma solidity ^0.8.0;

import "../character/Nokai.sol";
import "../tokens/ticket/HolyCore.sol";
import "../tokens/ticket/LegendCore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: MIT
contract NokaiGacha is Ownable {
    Nokai private nokai;
    HolyCore private holyCore;
    LegendCore private legendCore;

    constructor(address _nokai, address _holyCore, address _legendCore) {
        nokai = Nokai(_nokai);
        holyCore = HolyCore(_holyCore);
        legendCore = LegendCore(_legendCore);
    }

    function quickOpen(uint256 _number) external payable returns (uint256[] memory) {
        require(_number <= 10, "Gacha opener limited to 10 at once.");
        require(holyCore.isPurchaseAllowed(), "Purchase is closed at the moment.");
        uint256 cost = holyCore.costPerUnit() * _number;
        require(msg.value == cost, "Fund insufficient to validate the purchase.");

        uint256[] memory ids = new uint256[](_number);
        for (uint256 i = 0; i < _number; i++) {
            ids[i] = nokai.generateNokai(false);
        }
        return ids;
    }

    function openCore(uint256 _number) external returns (uint256[] memory) {
        require(_number <= 10, "Gacha opener limited to 10 at once.");
        require(holyCore.balanceOf(msg.sender) >= _number, "Insufficient number of HolyCore in your possession.");
        holyCore.consume(msg.sender, _number);
        uint256[] memory ids = new uint256[](_number);
        for (uint256 i = 0; i < _number; i++) {
            ids[i] = nokai.generateNokai(false);
        }
        return ids;
    }

    function openArtefact(uint256 _number) external returns (uint256[] memory) {
        require(_number <= 10, "Gacha opener limited to 10 at once.");
        require(legendCore.balanceOf(msg.sender) >= _number, "Insufficient number of LegendCore in your possession.");
        legendCore.consume(msg.sender, _number);
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
        return legendCore.balanceOf(msg.sender);
    }

    /**
     * Withdraw earnings from the purchase of Nokai through quickOpen
     */
    function withdraw() external onlyOwner {
        (bool success,) = msg.sender.call{value : address(this).balance}("withdraw sells");
        require(success, "withdraw failed");
    }
}
