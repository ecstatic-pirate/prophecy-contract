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
    address public client;
    address payable public admin;

    // address private contractor;
    // address private client;
    // address private admin;

    mapping(address => uint256) private _deposits;

    function deposit(address payable payee, address payable broker) public payable virtual onlyOwner {
        contractor = payee;
        client=msg.sender;
        admin = broker;
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }
    
    //validation function

    bool private taskCompleted;
    bool private taskValidated;
    bool private adminResolution;
    uint256 private adminDecision;
 
//  event Withdrawn(address indexed payee, uint256 weiAmount);

    //   function withdraw(address payable payee) public virtual onlyOwner {
    //     uint256 payment = _deposits[payee];

    //     _deposits[payee] = 0;

    //     payee.sendValue(payment);

    //     emit Withdrawn(payee, payment);
    // }

    function adminResolutionStatus(bool inputAdminResolution, uint256 inputAdminDecision) public virtual{
    adminResolution = inputAdminResolution;
    adminDecision = inputAdminDecision;
    }

    function taskValidationStatus(bool inputTaskValidated) public virtual{
    taskValidated = inputTaskValidated;
    }

    function taskCompletionStatus(bool inputTaskCompleted) public virtual{
    taskCompleted = inputTaskCompleted;
    }



    function withdrawalAllowed() public view virtual returns (bool){
        if(taskCompleted == true && taskValidated == true){
            return true;
        }
        else if(adminResolution == true){return true;}
        else {return false;}
    }
    
    function testPayment() public virtual{
    uint256 contractBalance = address(this).balance;
    uint256 adminPayment = (contractBalance * 2)/10; //admin fee to be added
    uint256 balancePayment = contractBalance - adminPayment;


        if((taskCompleted == true && taskValidated == true)||(adminResolution == true && adminDecision == 1)){
            contractor.sendValue(balancePayment);
            admin.sendValue(adminPayment);
        }
        else if(adminResolution == true && adminDecision == 0){
            // pay client
            }

    }

    // event Withdrawn(address indexed payee, uint256 weiAmount);
    // function withdraw(address payable payee) public virtual onlyOwner {
    //     uint256 payment = _deposits[payee];

    //     _deposits[payee] = 0;

    //     payee.sendValue(payment);

    //     emit Withdrawn(payee, payment);
    // }

    // function withdraw(address payable payee) public virtual override {
    //     require(withdrawalAllowed(payee), "ConditionalEscrow: payee is not allowed to withdraw");
    //     super.withdraw(payee);
    // }

}