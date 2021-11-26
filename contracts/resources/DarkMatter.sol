pragma solidity ^0.8.0;

import "./Resource.sol";

// SPDX-License-Identifier: MIT
contract DarkMatter is Resource {
    constructor(uint256 _cost) Resource("DarkMatter", "DARK") {
    }
}
