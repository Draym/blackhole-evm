pragma solidity ^0.8.0;

import "./Resource.sol";

// SPDX-License-Identifier: MIT
contract PlasmaEnergy is Resource {
    constructor(uint256 _cost) Resource("PlasmaEnergy", "PLAY") {
    }
}