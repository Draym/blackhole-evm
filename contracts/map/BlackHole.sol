pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
contract BlackHole {

    uint16 maxX;
    uint16 maxY;
    // address represent the owner of the board position
    address[] public board;

    constructor(uint16 _width, uint16 _height)  {
        maxX = _width;
        maxY = _height;
        board = new address[](maxX * maxY);
    }
}