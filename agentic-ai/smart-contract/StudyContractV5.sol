// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract StudyContractV5 {

    address public admin;

    constructor(address _admin) {
        require(_admin != address(0), "Invalid admin");
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    /* -----------------------------------------------------
        GLOBAL DIGEST (CDM/PHR/SEARCH 등) — admin only
    ----------------------------------------------------- */
    mapping(string => bytes32) private globalDigests;
    mapping(string => bool) private globalDigestExists;
    string[] private globalDigestKeys;

    event GlobalDigestSet(string key, bytes32 digest);

    function setGlobalDigest(string calldata key, bytes32 digest)
        external
        onlyAdmin
    {
        if (!globalDigestExists[key]) {
            globalDigestKeys.push(key);
        }

        globalDigests[key] = digest;
        globalDigestExists[key] = true;

        emit GlobalDigestSet(key, digest);
    }

    function getGlobalDigest(string calldata key)
        external
        view
        returns (bytes32)
    {
        require(globalDigestExists[key], "Digest missing");
        return globalDigests[key];
    }

    function getGlobalDigestKeys()
        external
        view
        returns (string[] memory)
    {
        return globalDigestKeys;
    }


    /* -----------------------------------------------------
        STUDY STRUCT (원본 V5 그대로 유지)
    ----------------------------------------------------- */
    struct Study {
        address researcher;
        string containerPk;
        uint256 f1;
        uint256 f2;
        uint256 f3;
        uint256 totalFee;
        bytes32 digest;          // 기존 digest 유지
        string status;
        address[] participants;

        // 추가된 digest 검증 결과 테이블
        mapping(string => bool) digestVerified;
        string[] verifiedKeys;
    }

    mapping(uint256 => Study) private studies;

    /* -----------------------------------------------------
        PAY INFO 구조 (그대로 유지)
    ----------------------------------------------------- */
    struct PayInfo {
        address user;
        uint256 amount;
    }

    mapping(uint256 => PayInfo[]) public studyPayments;

    /* -----------------------------------------------------
        EVENTS (원본 + 신규 일부 추가)
    ----------------------------------------------------- */
    event StudyCreated(uint256 studyId, address researcher, uint256 f1);
    event FeePaid(uint256 studyId, uint256 f1, uint256 f2, uint256 f3, uint256 total);
    event StatusUpdated(uint256 studyId, string status);
    event DigestUpdated(uint256 studyId, bytes32 digest);
    event ParticipantAdded(uint256 studyId, address provider);
    event DigestVerified(uint256 studyId, string key, bool matched);

    event IncomeDistributedFull(
        uint256 studyId,
        address[] users,
        uint256[] amounts
    );

    /* -----------------------------------------------------
        F1 + digest 검증 기능 추가
    ----------------------------------------------------- */
    function createStudy(
        uint256 studyId,
        string calldata containerPk,
        bytes32 digest
    ) external payable {
        require(studies[studyId].researcher == address(0), "Already exists");
        require(msg.value > 0, "F1 required");

        Study storage s = studies[studyId];
        s.researcher = msg.sender;
        s.containerPk = containerPk;
        s.f1 = msg.value;
        s.totalFee = msg.value;
        s.digest = digest;
        s.status = "CREATED";

        emit StudyCreated(studyId, msg.sender, msg.value);
        emit StatusUpdated(studyId, "CREATED");
    }

    /* -----------------------------------------------------
        digest 검증 기능 (신규)
    ----------------------------------------------------- */
    function verifyDigest(
        uint256 studyId,
        string calldata key,
        bytes32 workerDigest
    ) external onlyAdmin returns (bool) {

        require(globalDigestExists[key], "Global digest missing");

        Study storage s = studies[studyId];
        bool matched = (globalDigests[key] == workerDigest);

        s.digestVerified[key] = matched;
        s.verifiedKeys.push(key);

        emit DigestVerified(studyId, key, matched);
        return matched;
    }

    function getStudyDigestVerified(uint256 studyId, string calldata key)
        external
        view
        returns (bool)
    {
        return studies[studyId].digestVerified[key];
    }

    function getStudyVerifiedKeys(uint256 studyId)
        external
        view
        returns (string[] memory)
    {
        return studies[studyId].verifiedKeys;
    }

    /* -----------------------------------------------------
        F2 (원본 유지)
    ----------------------------------------------------- */
    function payAnalysisFee(uint256 studyId) external payable {
        Study storage s = studies[studyId];
        require(s.researcher == msg.sender, "Not owner");
        require(msg.value > 0, "F2 required");

        s.f2 += msg.value;
        s.totalFee += msg.value;

        emit FeePaid(studyId, s.f1, s.f2, s.f3, s.totalFee);
    }

    /* -----------------------------------------------------
        F3 (원본 유지)
    ----------------------------------------------------- */
    function payResultFee(uint256 studyId) external payable {
        Study storage s = studies[studyId];
        require(s.researcher == msg.sender, "Not owner");
        require(msg.value > 0, "F3 required");

        s.f3 += msg.value;
        s.totalFee += msg.value;

        emit FeePaid(studyId, s.f1, s.f2, s.f3, s.totalFee);
    }

    /* -----------------------------------------------------
        STATUS UPDATE (원본 유지)
    ----------------------------------------------------- */
    function updateStudyStatus(uint256 studyId, string calldata status) external onlyAdmin {
        studies[studyId].status = status;
        emit StatusUpdated(studyId, status);
    }

    /* -----------------------------------------------------
        원본 updateDigest (호환성 때문에 KEEP)
    ----------------------------------------------------- */
    function updateDigest(uint256 studyId, bytes32 digest) external onlyAdmin {
        studies[studyId].digest = digest;
        emit DigestUpdated(studyId, digest);
    }

    /* -----------------------------------------------------
        PARTICIPANTS (원본 유지)
    ----------------------------------------------------- */
    function addStudyParticipant(uint256 studyId, address provider) external onlyAdmin {
        require(provider != address(0), "Invalid provider");
        studies[studyId].participants.push(provider);
        emit ParticipantAdded(studyId, provider);
    }

    /* -----------------------------------------------------
        DISTRIBUTE (원본 유지)
    ----------------------------------------------------- */
    function distributeIncome(
        uint256 studyId,
        address[] calldata completedList
    ) external onlyAdmin {

        Study storage s = studies[studyId];

        require(s.totalFee > 0, "No fee");
        require(completedList.length > 0, "No completed participants");

        uint256 total = s.totalFee;

        uint256 adminReward = (total * 40) / 100;
        uint256 providerTotal = total - adminReward;
        uint256 eachReward = providerTotal / completedList.length;

        payable(admin).transfer(adminReward);
        studyPayments[studyId].push(PayInfo(admin, adminReward));

        for (uint i = 0; i < completedList.length; i++) {
            payable(completedList[i]).transfer(eachReward);
            studyPayments[studyId].push(PayInfo(completedList[i], eachReward));
        }

        s.totalFee = 0;

        address[] memory users = new address[](completedList.length + 1);
        uint256[] memory amounts = new uint256[](completedList.length + 1);

        users[0] = admin;
        amounts[0] = adminReward;

        for (uint i = 0; i < completedList.length; i++) {
            users[i + 1] = completedList[i];
            amounts[i + 1] = eachReward;
        }

        emit IncomeDistributedFull(studyId, users, amounts);
    }

    /* -----------------------------------------------------
        GETTERS (원본 100% 유지)
    ----------------------------------------------------- */

    function getStudyBasic(uint256 studyId)
        external view
        returns (
            address researcher,
            string memory containerPk,
            string memory status,
            bytes32 digest
        )
    {
        Study storage s = studies[studyId];
        return (s.researcher, s.containerPk, s.status, s.digest);
    }

    function getStudyFee(uint256 studyId)
        external view
        returns (uint256 f1, uint256 f2, uint256 f3, uint256 totalFee)
    {
        Study storage s = studies[studyId];
        return (s.f1, s.f2, s.f3, s.totalFee);
    }

    function getStudyMeta(uint256 studyId)
        external view
        returns (
            address researcher,
            uint256 f1,
            uint256 f2,
            uint256 f3,
            uint256 totalFee,
            string memory status,
            bytes32 digest,
            uint256 participantsCount
        )
    {
        Study storage s = studies[studyId];
        return (
            s.researcher,
            s.f1,
            s.f2,
            s.f3,
            s.totalFee,
            s.status,
            s.digest,
            s.participants.length
        );
    }

    function getParticipantCount(uint256 studyId) external view returns (uint256) {
        return studies[studyId].participants.length;
    }

    function getParticipantByIndex(uint256 studyId, uint256 index)
        external view
        returns (address)
    {
        return studies[studyId].participants[index];
    }

    function getAllParticipants(uint256 studyId)
        external view
        returns (address[] memory)
    {
        return studies[studyId].participants;
    }

    function getPaymentHistory(uint256 studyId)
        external
        view
        returns (PayInfo[] memory)
    {
        return studyPayments[studyId];
    }
}

