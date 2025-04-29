// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedElection {
    address public admin;

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    uint public candidatesCount;
    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public hasVoted;

    constructor() {
        admin = msg.sender;
    }

    // Function to add a candidate (only admin)
    function addCandidate(string memory _name) public {
        require(msg.sender == admin, "Only admin can add candidates");
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    // Function to vote for a candidate
    function vote(uint _candidateId) public {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
    }

    // Get total votes of a candidate
    function getVotes(uint _candidateId) public view returns (uint) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");
        return candidates[_candidateId].voteCount;
    }

    // Get all candidates
    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](candidatesCount);
        for (uint i = 1; i <= candidatesCount; i++) {
            candidateList[i - 1] = candidates[i];
        }
        return candidateList;
    }
    
    // Function to reset the election (only admin)
    function resetElection() public {
        require(msg.sender == admin, "Only admin can reset the election");

        // Reset candidates
        for (uint i = 1; i <= candidatesCount; i++) {
            delete candidates[i];
        }
        candidatesCount = 0;
        for (uint i = 0; i < 100; i++) {
            // Placeholder: In practice, you'd need to track voter addresses separately to reset.
        }
    }

    // Function to change the admin (only current admin)
    function changeAdmin(address _newAdmin) public {
        require(msg.sender == admin, "Only current admin can change admin");
        require(_newAdmin != address(0), "Invalid address for new admin");
        admin = _newAdmin;
    }
    // Get the winner candidate
    function getWinner() public view returns (uint, string memory, uint) {
        require(candidatesCount > 0, "No candidates available");

        uint winningVoteCount = 0;
        uint winningCandidateId = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        Candidate memory winner = candidates[winningCandidateId];
        return (winner.id, winner.name, winner.voteCount);
    }
    // NEW FUNCTION: Get details of a single candidate by ID
    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    // Get total votes cast in the election
    function getTotalVotes() public view returns (uint) {
        uint totalVotes = 0;
        for (uint i = 1; i <= candidatesCount; i++) {
            totalVotes += candidates[i].voteCount;
        }
        return totalVotes;
    }
    // Get the percentage of total votes a candidate has received
    function getVotePercentage(uint _candidateId) public view returns (uint) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate");
        uint totalVotesCast = getTotalVotes();
        if (totalVotesCast == 0) {
            return 0;
        }
        return (candidates[_candidateId].voteCount * 100) / totalVotesCast;
    }
}
