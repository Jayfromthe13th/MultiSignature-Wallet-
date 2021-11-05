pragma solidity 0.8.9;

contract Wallet {
    
        address [] public owners; //Stores owners of wallet
        uint limit;    //number of ownees who needs to sign off
        uint balance;
    
    
    struct Transfer{
        uint amount;
        address payable receiver ;
        uint approvals;
        bool hasBeenSent;
        uint txid;
    }
    
    event TransferRequestCreated(uint _txid, uint _amount, address _initiator, address _receiver);
    event ApprovalReceived(uint _txid, uint _approvals, address _approver);
    event TransferApproved(uint _txid);


    Transfer[] transferRequests; 
   //mapping[address][transferID]=> true/false
   
   mapping(address => mapping(uint => bool)) approvals; 
  
   modifier onlyOwner(){
        bool owner = false;
        for (uint i = 0; i < owners.length; i++){
            if(owners[i] == msg.sender){
            owner = true;
            }   
        }
  require(owner == true, "You don't have permission to execute onlyOwner.");
        _;
        
}

   
 constructor(address[] memory _owners, uint _limit) {
        
        owners = _owners;
       limit = _limit; 
     
 }
   
       
function getBalance() public view returns (uint) {
    return balance; 
}
       
function createTransfer(uint _amount, address payable _receiver) public onlyOwner {
    emit TransferRequestCreated(transferRequests.length, _amount, msg.sender, _receiver);
    require(balance >= _amount, "Insufficient funds");
    transferRequests.push(
        Transfer(_amount, _receiver, 0, false,transferRequests.length));
   
    }
function getTransferRequests() public view returns (Transfer[]memory) {
    return transferRequests;
}

function deposite() public payable {
    balance += msg.value;
}

function approve(uint _txid) public onlyOwner {
    
   require(approvals[msg.sender][_txid] == false);
        require(transferRequests[_txid].hasBeenSent == false);
        
        approvals[msg.sender][_txid] == true;
        transferRequests[_txid].approvals++;
        
        emit ApprovalReceived(_txid, transferRequests[_txid].approvals, msg.sender);
       
        if(transferRequests[_txid].approvals >= limit){
            transferRequests[_txid].hasBeenSent == true;
            transferRequests[_txid].receiver.transfer(transferRequests[_txid].amount);
            emit TransferApproved(_txid);
      
    }
}

}


