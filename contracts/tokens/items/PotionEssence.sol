pragma solidity ^0.8.0;

import "../Item.sol";

contract PotionEssence is Item {
    constructor() Resource("PotionEssence", "LIFE") {
    }
}
