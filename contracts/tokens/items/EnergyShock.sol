pragma solidity ^0.8.0;

import "../Item.sol";

contract EnergyShock is Item {
    constructor() Resource("EnergyShock", "ENGY") {
    }
}
