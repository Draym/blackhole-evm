pragma solidity ^0.8.0;

import "../character/Nokai.sol";
import "../tokens/ticket/HolyCore.sol";
import "../tokens/ticket/LegendaryCore.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// SPDX-License-Identifier: MIT
contract NokaiGacha is Ownable {
    Nokai private _nokai;
    HolyCore private _holyCore;
    LegendaryCore private _legendaryCore;

    constructor(address nokai, address holyCore, address legendaryCore) {
        _nokai = Nokai(nokai);
        _holyCore = HolyCore(holyCore);
        _legendaryCore = LegendaryCore(legendaryCore);
    }

    function quickOpen(uint256 number) external payable returns (uint256[] memory) {
        require(number <= 10, "Gacha opener limited to 10 at once.");
        require(_holyCore.isPurchaseAllowed(), "Purchase is closed at the moment.");
        uint256 cost = _holyCore.costPerUnit() * number;
        require(msg.value == cost, "Fund insufficient to validate the purchase.");

        uint256[] memory ids = new uint256[](number);
        for (uint256 i = 0; i < number; i++) {
            ids[i] = _nokai.generateNokai(false);
        }
        return ids;
    }

    function openCore(uint256 number) external returns (uint256[] memory) {
        require(number <= 10, "Gacha opener limited to 10 at once.");
        require(_holyCore.balanceOf(msg.sender) >= number, "Insufficient number of HolyCore in your possession.");
        _holyCore.consume(msg.sender, number);
        uint256[] memory ids = new uint256[](number);
        for (uint256 i = 0; i < number; i++) {
            ids[i] = _nokai.generateNokai(false);
        }
        return ids;
    }

    function openArtefact(uint256 number) external returns (uint256[] memory) {
        require(number <= 10, "Gacha opener limited to 10 at once.");
        require(_legendaryCore.balanceOf(msg.sender) >= number, "Insufficient number of LegendaryCore in your possession.");
        _legendaryCore.consume(msg.sender, number);
        uint256[] memory ids = new uint256[](number);
        for (uint256 i = 0; i < number; i++) {
            ids[i] = _nokai.generateNokai(true);
        }
        return ids;
    }

    function available() external view returns (uint256) {
        return _holyCore.balanceOf(msg.sender);
    }

    function availableSpecial() external view returns (uint256) {
        return _legendaryCore.balanceOf(msg.sender);
    }

    /**
     * Withdraw earnings from the purchase of Nokai through quickOpen
     */
    function withdraw() external onlyOwner {
        (bool success,) = msg.sender.call{value : address(this).balance}("withdraw sells");
        require(success, "withdraw failed");
    }
}
