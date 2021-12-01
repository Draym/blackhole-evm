pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// SPDX-License-Identifier: MIT
abstract contract BuyableToken is ERC20, AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");

    uint256 public cost;
    bool public isPurchaseAllowed;

    function adjustCost(uint256 _cost) external onlyRole(MODERATOR_ROLE) {
        cost = _cost;
    }

    function allowPurchase(bool _value) external onlyRole(MODERATOR_ROLE) {
        isPurchaseAllowed = _value;
    }

    function purchase(uint256 _number) external payable {
        require(isPurchaseAllowed == true, "purchase is closed at the moment");
        uint256 _cost = cost * _number;
        require(msg.value == _cost, "fund insufficient to validate the purchase");
        _mint(msg.sender, _number);
    }

    /**
     * Withdraw earnings from the purchase of cores
     * only available for given WITHDRAW_ROLE
     */
    function withdraw() external onlyRole(WITHDRAW_ROLE) {
        (bool success,) = msg.sender.call{value : address(this).balance}("withdraw eth");
        require(success, "withdraw failed");
    }

}
