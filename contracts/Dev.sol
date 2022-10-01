// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Escrow is Ownable {
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    address public contractor;
    address public client;
    address public admin;

    mapping(address => uint256) private _deposits;

    // function depositsOf(address payee) public view returns (uint256) {
    //     return _deposits[payee];
    // }

    // function deposit(address payee) public payable virtual onlyOwner {
    //     contractor = payee;
    //     uint256 amount = msg.value;
    //     _deposits[payee] += amount;
    //     emit Deposited(payee, amount);
    // }

    function deposit(address payee, address broker) public payable virtual onlyOwner {
        contractor = payee;
        client=msg.sender;
        admin = broker;
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }

}



abstract contract ConditionalEscrow is Escrow {
    /**
     * @dev Returns whether an address is allowed to withdraw their funds. To be
     * implemented by derived contracts.
     * @param payee The destination address of the funds.
     */
    function withdrawalAllowed(address payee) public view virtual returns (bool);

    function withdraw(address payable payee) public virtual override {
        require(withdrawalAllowed(payee), "ConditionalEscrow: payee is not allowed to withdraw");
        super.withdraw(payee);
    }
}


//create a new view only function to view addresses{Optional, define addresses as public to access them directly}

    function getContractorAddress() public view returns (address){
        return contractor;
    }

       function getClientAddress() public view returns (address){
        return client;
    }

       function getAdminAddress() public view returns (address){
        return admin;
    }