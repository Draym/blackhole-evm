pragma solidity ^0.8.0;

import "../resources/HolyCore.sol";

// SPDX-License-Identifier: MIT
contract CraftFactory {
    HolyCore private holyCore;

    constructor(address _holyCore) {
        holyCore = HolyCore(_holyCore);
    }

    function craftHolyCore(uint256 _number) external {

    }
}