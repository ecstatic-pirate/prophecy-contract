// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Escrow is Ownable {

    using Address for address payable;

    event Deposited(address indexed, uint256 weiAmount);
    event ContractorAdded(address indexed, address indexed contractorAddress);
    event AdminAdded(address indexed, address indexed adminAddress);
    event ClientAdded(address indexed, address indexed clientAddress);
    event TaskCompleted(address indexed, bool indexed inputTaskCompleted);
    event TaskValidated(address indexed, bool indexed inputTaskValidated);
    event AdminResolutionDone(address indexed ,bool indexed inputAdminResolution,bool indexed inputAdminDecision);
    event ContractorPaid(uint256 indexed balancePayment);
    event ClientPaid(uint256 indexed balancePayment);
    event AdminPaid(uint256 indexed adminPayment);

    address payable private contractor;
    address payable private client;
    address payable private admin;

// Activate hardcoded address later
    // address constant private admin = payable(ADDRESS_HERE);


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

// Check Client Function
// Checks if a given address is the client and only allows access to specific functions with the client address
    
    function _checkClient() internal view {
        require(msg.sender == client, "caller is not the client");
    }

      modifier onlyClient() {
        _checkClient();
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

    function deposit() public payable onlyClient {
        uint256 amount = msg.value;
        emit Deposited(msg.sender, amount);
    }

// Add Contractor Wallet Address function
// Client adds the wallet address of the contractor
// Only the client can call the function

    
    uint256 private contractorState;
    function addContractor(address payable contractorAddress) public onlyOwner{
        require(contractorState <1 , "Contractor Address cannot be changed once added");
        require(contractorAddress != client , "Contractor Address cannot be the same as Client Address");
        contractor = contractorAddress;
        contractorState += 1;
        emit ContractorAdded(msg.sender,contractorAddress);
    }

// Add Admin Wallet Address function 
//{OPTIONAL: BETTER TO HARDCODE THE ADDRESS TO PROTECT THE FUNCTION FROM BEING MISUESD AS ADMIN HAS THE POWER TO RESOLVE PAYMENTS}
// Client adds the wallet address of the admin
// Only the Contract Owner(creator) can call the function   

    function addAdmin(address payable adminAddress) public {
        admin = adminAddress;
        emit AdminAdded(msg.sender,adminAddress);
    }

// Add Admin Wallet Address function 
// {OPTIONAL: BETTER TO HARDCODE THE ADDRESS TO PROTECT THE FUNCTION FROM BEING MISUESD AS ADMIN HAS THE POWER TO RESOLVE PAYMENTS}
// Client adds the wallet address of the admin
// Only the Contract Owner(creator) can call the function   

    uint256 private clientState;
    function addClient(address payable clientAddress) public onlyOwner{
        require(clientState <1 , "Client Address cannot be changed once added");
        require(clientAddress != contractor , "Client Address cannot be the same as  Contractor Address");
        client = clientAddress;
        clientState +=1;
        emit ClientAdded(msg.sender,clientAddress);
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
    emit AdminResolutionDone(msg.sender,inputAdminResolution,inputAdminDecision);
    }

// taskCompletionStatus Function
// Takes taskCompleted status
// If true, the contractor gets paid. If false, the client gets paid.
// The function can only be accessed by the contractor address        

    function taskCompletionStatus(bool inputTaskCompleted) public onlyContractor {
    require(address(this).balance !=0 , "Add funds to the contract");
    taskCompleted = inputTaskCompleted;
    emit TaskCompleted(msg.sender, inputTaskCompleted);
    }

// taskValidationStatus Function
// Takes taskValidation status and calls the withdrawPayment function.
// If true, the contractor gets paid.
// The function can only be accessed by the client address        

    function taskValidationStatus(bool inputTaskValidated) public onlyClient{
    require(address(this).balance !=0 , "Add funds to the contract");
    require(taskCompleted=true,"Task not completed yet");
    taskValidated = inputTaskValidated;
    withdrawPayment();
    emit TaskValidated(msg.sender,inputTaskValidated);
    }

// withdrawPayment function
// Settles payments based on conditions    
// if taskCompleted is TRUE and taskValidate is TRUE or if adminResolution is TRUE and adminPayContractor is TRUE pays CONTRACTOR
// else if adminResolution is TRUE and adminPayContractor is FALSE pays CLIENT

    function withdrawPayment() private{
    uint256 balancePayment = address(this).balance;
    uint256 adminPayment = (balancePayment * 2)/100; //admin fee to be added based on the real time crypto value. 
    balancePayment -= adminPayment; //updates the contract balance value


        if((taskCompleted == true && taskValidated == true)||(adminResolution == true && adminPayContractor == true)){
            contractor.sendValue(balancePayment);
            admin.sendValue(adminPayment);
            emit ContractorPaid(balancePayment);
            emit AdminPaid(adminPayment);
        }
        else if(adminResolution == true && adminPayContractor == false){
            client.sendValue(balancePayment);
            admin.sendValue(adminPayment);
            emit ClientPaid(balancePayment);
            emit AdminPaid(adminPayment);
            }

    }

}
