pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// SPDX-License-Identifier: MIT
abstract contract BurnableToken is ERC20, AccessControl {
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    function consume(uint256 _number) external onlyRole(BURNER_ROLE) {
        require(balanceOf(msg.sender) >= _number, "user do not own enough cores");
         _burn(msg.sender, _number);
    }
}
