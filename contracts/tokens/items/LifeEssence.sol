pragma solidity ^0.8.0;

import "../Item.sol";

contract LifeEssence is Item {
    constructor() Resource("LifeEssence", "BORN") {
    }
}
