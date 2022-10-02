// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Escrow is Ownable {

    using Address for address payable;

    event Deposited(uint256 weiAmount);
    event ContractorAdded(address indexed payee);
    event AdminAdded(address indexed payee);

    address payable private contractor;
    address payable private client;
    address payable private admin;

    mapping(address => uint256) private _deposits;

// Check Admin Function
// Checks if a given address is the admin and only allows access to specific functions with the admin address
    
    function _checkAdmin() internal view {
        require(msg.sender == admin, "caller is not the admin");
    }

      modifier onlyAdmin() {
        _checkAdmin();
        _;
    }

// Check Contractor Function
// Checks if a given address is the contractor and only allows access to specific functions with the contractor address


    function _checkContractor() internal view {
        require(msg.sender == contractor, "caller is not the contractor");
    }

      modifier onlyContractor() {
        _checkContractor();
        _;
    }


 // Deposit function
 // Client sends the slected money to the smart contract
 // Can Only be called by the client. 

    function deposit() public payable onlyOwner {
        client= payable(msg.sender);
        uint256 amount = msg.value;
        emit Deposited(amount);
    }

// Add Contractor Wallet Address function
// Client adds the wallet address of the contractor
// Only the client can call the function
    
     function addContractor(address payable payee) public onlyOwner{
        contractor = payee;
        emit ContractorAdded(payee);
    }

// Add Admin Wallet Address function 
//{OPTIONAL: BETTER TO HARDCODE THE ADDRESS TO PROTECT THE FUNCTION FROM BEING MISUESD AS ADMIN HAS THE POWER TO RESOLVE PAYMENTS}
// Client adds the wallet address of the admin
// Only the client can call the function   

    function addAdmin(address payable payee) public {
        admin = payee;
        emit AdminAdded(payee);
    }

// Declaring status check variables
// taskCompleted: True once the contractor marks the tasks as done
// taskValidated: True once the client marks the tasks as validated
// adminResolution: True when the admin needs to resolve the contract in case of a dispute
// adminPayContractor: True when the admin decides to pay the contractor, false when the admin decides to pay the client

    bool private taskCompleted;
    bool private taskValidated;
    bool private adminResolution;
    bool private adminPayContractor;
   
// adminResolutionStatus Function
// Takes adminResolution and adminPayContractor. And calls the withdrawPayment function.
// The function can only be accessed by the admin address    

    function adminResolutionStatus(bool inputAdminResolution, bool inputAdminDecision) public onlyAdmin{
    adminResolution = inputAdminResolution;
    adminPayContractor = inputAdminDecision;
    withdrawPayment();
    }

// taskCompletionStatus Function
// Takes taskCompleted status
// If true, the contractor gets paid. If false, the client gets paid.
// The function can only be accessed by the contractor address        

    function taskCompletionStatus(bool inputTaskCompleted) public onlyContractor {
    taskCompleted = inputTaskCompleted;
    }

// taskValidationStatus Function
// Takes taskValidation status and calls the withdrawPayment function.
// If true, the contractor gets paid.
// The function can only be accessed by the client address        

    function taskValidationStatus(bool inputTaskValidated) public onlyOwner{
    taskValidated = inputTaskValidated;
    withdrawPayment();
    }

// withdrawPayment function
// Settles payments based on conditions    
// if taskCompleted is TRUE and taskValidate is TRUE or if adminResolution is TRUE and adminPayContractor is TRUE pays CONTRACTOR
// else if adminResolution is TRUE and adminPayContractor is FALSE pays CLIENT

    function withdrawPayment() private{
    uint256 balancePayment = address(this).balance;
    uint256 adminPayment = (balancePayment * 2)/10; //admin fee to be added based on the real time crypto value. 
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