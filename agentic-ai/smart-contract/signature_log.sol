pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";

contract signature_log {

    address public owner;

    constructor() {
        owner = msg.sender;        
    }
     
    struct Signature {
        uint seq;
        string serviceId;
        string fromDid;        
        string signature;        
        string created;
        string updated;        
    }  

    mapping(string => Signature[]) public signatures;
    mapping(string => uint) public seqs;    

    function getNow() public view returns(string memory){        
        return Strings.toString(block.timestamp);
    }  

    function setSignature(string memory _serviceId,  
            string memory _fromDid, string memory _toDid, string memory _signature, uint _seq) public {                    
        require( owner == msg.sender,
            "You are not the owner of this contract.");      
        string memory nowTime = getNow();        
        signatures[_toDid].push(Signature(_seq, _serviceId, _fromDid, _signature, nowTime, nowTime));
        seqs[_toDid] = _seq;
    }
}
