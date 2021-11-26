pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// SPDX-License-Identifier: MIT
contract HolyCore is ERC20, AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    uint256 public cost;
    bool public isPurchaseAllowed;

    constructor(uint256 _cost) ERC20("HolyCore", "CORE") {
        cost = _cost;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function adjustCost(uint256 _cost) external onlyRole(MODERATOR_ROLE) {
        cost = _cost;
    }

    function allowPurchase(bool _value) external onlyRole(MODERATOR_ROLE) {
        isPurchaseAllowed = _value;
    }

    function consumeCore(uint256 _number) external onlyRole(BURNER_ROLE) {
        require(balanceOf(msg.sender) >= _number, "user do not own enough cores");
        _burn(msg.sender, _number);
    }

    function purchase(uint256 _number) external payable {
        require(isPurchaseAllowed == true, "purchase is closed at the moment");
        uint256 _cost = cost * _number;
        require(msg.value == _cost, "fund insufficient to validate the purchase");
        _mint(msg.sender, _number);
    }

    function craft(uint256 _number) external onlyRole(FACTORY_ROLE) {
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