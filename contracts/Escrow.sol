// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Escrow is Ownable {
    
    // Deposit function
    
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);

    address public contractor;
    address public client;
    address public admin;

    mapping(address => uint256) private _deposits;

    function deposit(address payee, address broker) public payable virtual onlyOwner {
        contractor = payee;
        client=msg.sender;
        admin = broker;
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }

}