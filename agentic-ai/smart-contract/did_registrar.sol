pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";

contract did_registrar {
    
    string public SCHEME = "did";
    string public METHOD = "avdid";
    address public owner;
    string[] public context = ["https://www.w3.org/ns/did/v1", "https://w3id.org/security/v1"];

    constructor() {
        owner = msg.sender;
    }

    struct Document {
        address owner;
        string[] context;
        string did;                
        /** 1:N */
        PublicKey[]  publicKeys;
        Authentication[]  authentications;
        Service[]  services;
        /** Timestamp **/
        string created;
        string updated;        
    }    

    struct PublicKey {
        string id;
        string PublicKeyType;
        string controller;
        string publicKey;
    }
    struct Authentication {
        string id;
        string authType;
        string controller;
        string publicKey;
    }
    struct Service {
        string id;
        string ServiceType;
        string publicKey;
        string serviceEndpoint;        
    }
       
    mapping(string => Document) public did2document;
    mapping(address => Document[]) private documents;
    
    mapping(string => Service[]) public services;
    mapping(string => Authentication[]) public authentications;
    mapping(string => PublicKey[]) public publicKeys;

    function getDocument(address _owner, uint _index)
    public
    view
    returns (
        address owner,
        string memory did,
        string memory created,
        string memory updated
    )
{
    Document storage doc = documents[_owner][_index];
    return (doc.owner, doc.did, doc.created, doc.updated);
}

    function substring(string memory str, uint startIndex, uint endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }
    function getNow() public view returns(string memory){        
        return Strings.toString(block.timestamp);
    }
    function getIdentifier(string memory _id) public view returns(string memory){                
        string memory hashStr = Strings.toHexString(uint256(keccak256(abi.encodePacked(string.concat(_id, getNow())))), 32);        
        return substring(hashStr, 2, 17);
    }    

    function createAuthentication(string memory _did,
            string memory _authType, 
            string memory _controller, 
            string memory _publicKey) public {    
        require(
            getLengthofDocuments() > 0,
            "No Document.");
        require( documents[msg.sender][getDocumentIndexByDid(_did)].owner == msg.sender,
            "You are not the owner of the document.");            
        // // _authId null check
        // bytes memory _authIdByte = bytes(_authId);
        string memory authId = string.concat(_did,"#","keys-",Strings.toString(authentications[_did].length));
        authentications[_did].push(Authentication(authId, _authType, _controller, _publicKey));                 
        documents[msg.sender][getDocumentIndexByDid(_did)].authentications=authentications[_did];
    } function upsertAuthentication(string memory _did,
            string memory _authId,
            string memory _authType, 
            string memory _controller, 
            string memory _publicKey) public {    
        require(
            getLengthofDocuments() > 0,
            "No Document.");
        require( documents[msg.sender][getDocumentIndexByDid(_did)].owner == msg.sender,
            "You are not the owner of the document.");
        uint structIndex = getStructIndexByDid(_did, _authId, "Authentication");
        authentications[_did][structIndex] = Authentication(_authId, _authType, _controller, _publicKey);                 

        documents[msg.sender][getDocumentIndexByDid(_did)].authentications=authentications[_did];
        documents[msg.sender][getDocumentIndexByDid(_did)].updated = getNow();
    }

    function createPublicKey(string memory _did, 
            string memory _publicKeyType, 
            string memory _controller, 
            string memory _publicKey) public {   
        require(
            getLengthofDocuments() > 0,
            "No Document.");
        require( documents[msg.sender][getDocumentIndexByDid(_did)].owner == msg.sender,
            "You are not the owner of the document.");     
        string memory publicKeyId = string.concat(_did,"#","keys-",Strings.toString(publicKeys[_did].length));
        publicKeys[_did].push(PublicKey(publicKeyId, _publicKeyType, _controller, _publicKey));         
        documents[msg.sender][getDocumentIndexByDid(_did)].publicKeys=publicKeys[_did];
    } function upsertPublicKey(string memory _did,
            string memory _publicKeyId,
            string memory _publicKeyType, 
            string memory _controller, 
            string memory _publicKey) public {    
        require(
            getLengthofDocuments() > 0,
            "No Document.");      
        require( documents[msg.sender][getDocumentIndexByDid(_did)].owner == msg.sender,
            "You are not the owner of the document.");      
        uint structIndex = getStructIndexByDid(_did, _publicKeyId, "PublicKey");
        publicKeys[_did][structIndex] = PublicKey(_publicKeyId, _publicKeyType, _controller, _publicKey);                 

        documents[msg.sender][getDocumentIndexByDid(_did)].publicKeys=publicKeys[_did];
        documents[msg.sender][getDocumentIndexByDid(_did)].updated = getNow();
    }


    function createService(string memory _did, 
            string memory _serviceType,  
            string memory _publicKey,     
            string memory _serviceEndpoint) public {   
        require(
            getLengthofDocuments() > 0,
            "No Document.");
        require( documents[msg.sender][getDocumentIndexByDid(_did)].owner == msg.sender,
            "You are not the owner of the document.");   
        string memory serviceId = string.concat(_did,"#","keys-",Strings.toString(services[_did].length));
        services[_did].push(Service(serviceId, _serviceType, _publicKey, _serviceEndpoint));         
        documents[msg.sender][getDocumentIndexByDid(_did)].services=services[_did];
    } function upsertService(string memory _did,
            string memory _serviceId,  
            string memory _serviceType,  
            string memory _publicKey,     
            string memory _serviceEndpoint) public {    
        require(getLengthofDocuments() > 0,
            "No Document.");
        require( documents[msg.sender][getDocumentIndexByDid(_did)].owner == msg.sender,
            "You are not the owner of the document.");        
        uint structIndex = getStructIndexByDid(_did, _serviceId, "Authentication");
        services[_did][structIndex] = Service(_serviceId, _serviceType, _publicKey, _serviceEndpoint);                 

        documents[msg.sender][getDocumentIndexByDid(_did)].services=services[_did];
        documents[msg.sender][getDocumentIndexByDid(_did)].updated = getNow();
    }

    function createDocument(string memory _id,
            string memory authType,
            string memory authController,
            string memory authPublicKey
            ) public payable{
        
        // set DID
        string memory nowTime = getNow();
        string memory did = string.concat(SCHEME,":",METHOD,":",getIdentifier(_id));
        
        // set Timestamps  
        string memory created = nowTime;
        string memory updated = nowTime;

        Document storage docu = documents[msg.sender].push();
        docu.owner = msg.sender;
        docu.context = context;
        docu.did = did;
        // set Structs
        createPublicKey(did, authType, authController, authPublicKey);
        uint cnt = getLengthofDocuments()-1;
        PublicKey memory pk = publicKeys[did][cnt];
        createAuthentication(did, authType, pk.controller, pk.id);        
        // initial Service info
        string memory serviceType = "CredentialRepositoryService";
        string memory serviceEndPoint = "https://avchain.io";
        createService(did, serviceType, pk.id, serviceEndPoint);
        serviceType = "DIDResolver";
        serviceEndPoint = "https://avchain.io";
        createService(did, serviceType, pk.id, serviceEndPoint);
        serviceType = "DIDRegistrar";
        serviceEndPoint = "https://avchain.io";
        createService(did, serviceType, pk.id, serviceEndPoint);

        docu.created = created;
        docu.updated = updated;

        did2document[did] = docu;
    }

    function getLengthofDocuments() public view returns  (uint) {
        return documents[msg.sender].length;
    }
    function getDIDs() public view returns  (string[] memory) {
        string[] memory dids = new string[](documents[msg.sender].length);
        for (uint i=0; i<documents[msg.sender].length; i++){
            dids[i] = documents[msg.sender][i].did;
        }
        return dids;
    }

    function getDocumentIndexByDid(string memory _did) public view returns  (uint) {        
        for (uint i=0; i<documents[msg.sender].length; i++){            
            if (keccak256(abi.encodePacked(documents[msg.sender][i].did )) == keccak256(abi.encodePacked(_did))){
                return i;   }
            require(i<documents[msg.sender].length, "The DID is not registered." );            
        } 
        return (0);
    }
    function getStructIndexByDid(string memory _did, string memory _structId, string memory _structName) public view returns  (uint) {        
        uint didIndex = getDocumentIndexByDid(_did);
        uint structIndex = 0;
        
        if (keccak256(abi.encodePacked(_structName)) == keccak256(abi.encodePacked("Authentication"))){
            structIndex = documents[msg.sender][didIndex].authentications.length;    
            for (uint j=0; j<structIndex; j++){
                if (keccak256(abi.encodePacked(documents[msg.sender][didIndex].authentications[j].id )) 
                        == keccak256(abi.encodePacked(_structId))){
                    return j;}
                require(j<structIndex, "The DID Authentication is not registered." );            
            }        
        }
        else if (keccak256(abi.encodePacked(_structName)) == keccak256(abi.encodePacked("PublicKey"))){
            structIndex = documents[msg.sender][didIndex].publicKeys.length;
            for (uint j=0; j<structIndex; j++){
                if (keccak256(abi.encodePacked(documents[msg.sender][didIndex].publicKeys[j].id )) 
                        == keccak256(abi.encodePacked(_structId))){
                    return j;}
                require(j<structIndex, "The DID PublicKey is not registered." );            
            }   
        }
        else if (keccak256(abi.encodePacked(_structName)) == keccak256(abi.encodePacked("Service"))){
            structIndex = documents[msg.sender][didIndex].services.length;
            for (uint j=0; j<structIndex; j++){
                if (keccak256(abi.encodePacked(documents[msg.sender][didIndex].services[j].id )) 
                        == keccak256(abi.encodePacked(_structId))){
                    return j;}
                require(j<structIndex, "The DID Service is not registered." );            
            }
        }
        return (0);
    }
}
