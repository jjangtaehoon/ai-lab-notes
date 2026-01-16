// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DAOContractV5 {

    address public admin;

    constructor(address _admin) {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
        bool permitted;
        string[] role;
    }

    struct Dao {
        address chairperson;
        string name;
        uint voteCount;
        mapping(address => uint) balances;
        mapping(address => Voter) voters;
        address[] votersList;
    }

    mapping(uint => Dao) public Daos;

    /* ------------------- DAO 핵심 기능 그대로 ------------------- */

    function createDao(uint daoId, string memory name) public payable {
        require(msg.value >= 1 ether, "Need 1 ether");

        Dao storage d = Daos[daoId];
        d.chairperson = msg.sender;
        d.name = name;

        d.voters[msg.sender].weight = 1;
        d.voters[msg.sender].permitted = true;
        d.voters[msg.sender].role.push("Provider");

        d.balances[msg.sender] = msg.value;
        d.voteCount = 0;
        d.votersList.push(msg.sender);
    }

    function requestRightToVoteToProvider(uint daoId) public payable {
        require(msg.value >= 1 ether, "Need 1 ether");

        Dao storage d = Daos[daoId];
        require(d.voters[msg.sender].weight == 0, "Already has right");

        d.voters[msg.sender].weight = 1;
        d.voters[msg.sender].role.push("Provider");
        d.balances[msg.sender] += msg.value;
        d.votersList.push(msg.sender);
    }

    function registRequester(uint daoId) public payable {
        require(msg.value >= 1 ether, "Need 1 ether");

        Dao storage d = Daos[daoId];
        require(d.voters[msg.sender].weight == 0, "Already has right");

        d.voters[msg.sender].weight = 1;
        d.voters[msg.sender].role.push("Requester");
        d.balances[msg.sender] += msg.value;
        d.votersList.push(msg.sender);
    }

    function vote(uint daoId) public {
        Dao storage d = Daos[daoId];
        Voter storage sender = d.voters[msg.sender];

        require(sender.weight != 0, "No right");
        require(!sender.voted, "Already voted");

        sender.voted = true;
        sender.vote = daoId;
        d.voteCount += sender.weight;
        d.votersList.push(msg.sender);
    }

    function withdraw(uint daoId) public {
        Dao storage d = Daos[daoId];
        require(d.balances[msg.sender] > 0, "No balance");

        uint amount = d.balances[msg.sender];

        d.balances[msg.sender] = 0;
        d.voters[msg.sender].weight = 0;
        d.voters[msg.sender].voted = false;

        payable(msg.sender).transfer(amount);
    }

    /* ------------------- GETTER 추가 ------------------- */

    // DAO 기본 정보 조회
    function getDaoBasic(uint daoId)
        external
        view
        returns (
            address chairperson,
            string memory name,
            uint voteCount,
            uint votersCount
        )
    {
        Dao storage d = Daos[daoId];
        return (d.chairperson, d.name, d.voteCount, d.votersList.length);
    }

    // 특정 voter 조회
    function getDaoVoter(uint daoId, address voter)
        external
        view
        returns (
            uint weight,
            bool voted,
            uint voteNumber,
            bool permitted
        )
    {
        Voter storage v = Daos[daoId].voters[voter];
        return (v.weight, v.voted, v.vote, v.permitted);
    }

    // voter role 조회
    function getDaoVoterRoles(uint daoId, address voter)
        external
        view
        returns (string[] memory)
    {
        return Daos[daoId].voters[voter].role;
    }

    // voter 리스트 전체
    function getDaoVoters(uint daoId)
        external
        view
        returns (address[] memory)
    {
        return Daos[daoId].votersList;
    }

    // voter 잔액 조회
    function getDaoBalanceOf(uint daoId, address voter)
        external
        view
        returns (uint)
    {
        return Daos[daoId].balances[voter];
    }
}

