// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Escrow is Ownable {
    
    // Deposit function
    
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    

    address payable public contractor;
    address payable public client;
    address payable public admin;

    // address private contractor;
    // address private client;
    // address private admin;

    mapping(address => uint256) private _deposits;

    function deposit(address payable payee, address payable broker) public payable virtual onlyOwner {
        contractor = payee;
        client= payable(msg.sender);
        admin = broker;
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }
    
    //validation function

    bool private taskCompleted;
    bool private taskValidated;
    bool private adminResolution;
    bool private adminPayContractor;
 
//  event Withdrawn(address indexed payee, uint256 weiAmount);

    //   function withdraw(address payable payee) public virtual onlyOwner {
    //     uint256 payment = _deposits[payee];

    //     _deposits[payee] = 0;

    //     payee.sendValue(payment);

    //     emit Withdrawn(payee, payment);
    // }
    
    //setting up modifiers

    
    function _checkAdmin() internal view virtual {
        require(msg.sender == admin, "caller is not the admin");
    }

      modifier onlyAdmin() {
        _checkAdmin();
        _;
    }

    
    function _checkContractor() internal view virtual {
        require(msg.sender == contractor, "caller is not the contractor");
    }

      modifier onlyContractor() {
        _checkContractor();
        _;
    }
    //validation and withdraw functions

    function adminResolutionStatus(bool inputAdminResolution, bool inputAdminDecision) public virtual onlyAdmin{
    adminResolution = inputAdminResolution;
    adminPayContractor = inputAdminDecision;
    testPayment();
    }

    function taskCompletionStatus(bool inputTaskCompleted) public virtual onlyContractor {
    taskCompleted = inputTaskCompleted;
    }

    function taskValidationStatus(bool inputTaskValidated) public virtual onlyOwner{
    taskValidated = inputTaskValidated;
    testPayment();
    }

    function testPayment() public virtual{
    uint256 balancePayment = address(this).balance;
    uint256 adminPayment = (balancePayment * 2)/10; //admin fee to be added
    balancePayment -= adminPayment; //updates the contract balance value


        if((taskCompleted == true && taskValidated == true)||(adminResolution == true && adminPayContractor == true)){
            contractor.sendValue(balancePayment);
            admin.sendValue(adminPayment);
        }
        else if(adminResolution == true && adminPayContractor == false){
            client.sendValue(balancePayment);
            admin.sendValue(adminPayment);

            }

    }

}