// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract HealthInsurance {

    address public insurer;
    uint256 public reportCount;
    uint256 public claimCount;

    constructor() {
        insurer = msg.sender; // deployer is insurer
    }

    // ------------------ STRUCTS ------------------

    struct Report {
        uint256 id;
        address hospital;
        address user;
        bytes32 hospitalHash;
    }

    struct Claim {
        uint256 id;
        address user;
        uint256[] reportIds;
        bytes32 userHash;
        bool verified;
        bool approved;
        bool decided;
    }

    // ------------------ STORAGE ------------------

    mapping(uint256 => Report) public reports;
    mapping(uint256 => Claim) public claims;
    mapping(address => bool) public isHospital;

    // ------------------ MODIFIERS ------------------

    modifier onlyInsurer() {
        require(msg.sender == insurer, "Only insurer");
        _;
    }

    modifier onlyHospital() {
        require(isHospital[msg.sender], "Only hospital");
        _;
    }

    modifier validClaim(uint256 _id) {
        require(_id > 0 && _id <= claimCount, "Invalid claim");
        _;
    }

    modifier validReport(uint256 _id) {
        require(_id > 0 && _id <= reportCount, "Invalid report");
        _;
    }

    // ------------------ EVENTS ------------------

    event HospitalRegistered(address hospital);
    event HospitalReportStored(uint256 reportId, address hospital, address user);
    event ClaimApplied(uint256 claimId, address user);
    event UserHashSubmitted(uint256 claimId);
    event ClaimAutoVerified(uint256 claimId, bool matched);
    event ClaimApproved(uint256 claimId);
    event ClaimRejected(uint256 claimId);

    // ------------------ INSURER ------------------

    function registerHospital(address _hospital) external onlyInsurer {
        require(_hospital != address(0), "Invalid address");
        require(!isHospital[_hospital], "Already registered");

        isHospital[_hospital] = true;
        emit HospitalRegistered(_hospital);
    }

    // ------------------ HOSPITAL ------------------

    function storeHospitalHash(
        address _user,
        bytes32 _reportHash
    ) external onlyHospital {

        require(_user != address(0), "Invalid user");
        require(_reportHash != bytes32(0), "Empty hash");

        reportCount++;

        reports[reportCount] = Report(
            reportCount,
            msg.sender,
            _user,
            _reportHash
        );

        emit HospitalReportStored(reportCount, msg.sender, _user);
    }

    // ------------------ USER ------------------

    function applyClaim(uint256[] calldata _reportIds) external {
        require(_reportIds.length > 0, "No reports");

        for (uint256 i = 0; i < _reportIds.length; i++) {
            uint256 rid = _reportIds[i];
            require(reports[rid].user == msg.sender, "Not your report");
        }

        claimCount++;

        Claim storage c = claims[claimCount];
        c.id = claimCount;
        c.user = msg.sender;

        for (uint256 i = 0; i < _reportIds.length; i++) {
            c.reportIds.push(_reportIds[i]);
        }

        emit ClaimApplied(claimCount, msg.sender);
    }

    // ------------------ INSURER VERIFICATION ------------------

    function submitUserHash(
        uint256 _claimId,
        bytes32 _userHash
    ) external onlyInsurer validClaim(_claimId) {

        Claim storage c = claims[_claimId];
        require(!c.decided, "Already processed");
        require(_userHash != bytes32(0), "Empty hash");

        c.userHash = _userHash;

        emit UserHashSubmitted(_claimId);
    }

    function autoVerifyClaim(uint256 _claimId)
        external
        onlyInsurer
        validClaim(_claimId)
    {
        Claim storage c = claims[_claimId];
        require(c.userHash != bytes32(0), "User hash missing");

        bool matched = true;

        for (uint256 i = 0; i < c.reportIds.length; i++) {
            uint256 rid = c.reportIds[i];
            if (reports[rid].hospitalHash != c.userHash) {
                matched = false;
                break;
            }
        }

        c.verified = matched;
        c.decided = true;

        emit ClaimAutoVerified(_claimId, matched);
    }

    // ------------------ FINAL DECISION ------------------

    function finalDecision(
        uint256 _claimId,
        bool _approve
    ) external onlyInsurer validClaim(_claimId) {

        Claim storage c = claims[_claimId];
        require(c.decided, "Verify first");

        c.approved = _approve;

        if (_approve) {
            emit ClaimApproved(_claimId);
        } else {
            emit ClaimRejected(_claimId);
        }
    }

    // ------------------ HELPERS ------------------

    function getClaimReports(uint256 _claimId)
        external
        view
        returns (uint256[] memory)
    {
        return claims[_claimId].reportIds;
    }
}
