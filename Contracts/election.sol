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
    mapping(uint => Candidate) private candidates;
    mapping(address => bool) private hasVoted;
    address[] private voterList; // NEW: Track voters who voted

    // ----------- Modifiers -----------
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin allowed");
        _;
    }

    modifier validCandidate(uint _id) {
        require(_id > 0 && _id <= candidatesCount, "Invalid candidate ID");
        _;
    }

    modifier notVoted() {
        require(!hasVoted[msg.sender], "Already voted");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // ----------- Admin Functions -----------

    function addCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function updateCandidateName(uint _id, string memory _newName) public onlyAdmin validCandidate(_id) {
        candidates[_id].name = _newName;
    }

    function changeAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }

    function resetElection() public onlyAdmin {
        for (uint i = 1; i <= candidatesCount; i++) {
            delete candidates[i];
        }
        candidatesCount = 0;

        for (uint i = 0; i < voterList.length; i++) {
            hasVoted[voterList[i]] = false;
        }
        delete voterList;
    }

    // ----------- Voting Functions -----------

    function vote(uint _id) public notVoted validCandidate(_id) {
        hasVoted[msg.sender] = true;
        candidates[_id].voteCount++;
        voterList.push(msg.sender); // Track voter
    }

    // ----------- View Functions -----------

    function getCandidate(uint _id) public view validCandidate(_id) returns (uint, string memory, uint) {
        Candidate memory c = candidates[_id];
        return (c.id, c.name, c.voteCount);
    }

    function getAllCandidates() public view returns (Candidate[] memory) {
        Candidate[] memory list = new Candidate[](candidatesCount);
        for (uint i = 1; i <= candidatesCount; i++) {
            list[i - 1] = candidates[i];
        }
        return list;
    }

    function getCandidateNames() public view returns (string[] memory) {
        string[] memory names = new string[](candidatesCount);
        for (uint i = 1; i <= candidatesCount; i++) {
            names[i - 1] = candidates[i].name;
        }
        return names;
    }

    function getTotalVotes() public view returns (uint total) {
        for (uint i = 1; i <= candidatesCount; i++) {
            total += candidates[i].voteCount;
        }
    }

    function getAverageVotes() public view returns (uint) {
        if (candidatesCount == 0) return 0;
        uint total = getTotalVotes();
        return total / candidatesCount;
    }

    function getVotes(uint _id) public view validCandidate(_id) returns (uint) {
        return candidates[_id].voteCount;
    }

    function getVotePercentage(uint _id) public view validCandidate(_id) returns (uint) {
        uint total = getTotalVotes();
        if (total == 0) return 0;
        return (candidates[_id].voteCount * 100) / total;
    }

    function getWinner() public view returns (uint, string memory, uint) {
        require(candidatesCount > 0, "No candidates");
        uint maxVotes = 0;
        uint winnerId;

        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }

        Candidate memory winner = candidates[winnerId];
        return (winner.id, winner.name, winner.voteCount);
    }

    function getRunnerUp() public view returns (uint, string memory, uint) {
        require(candidatesCount > 1, "Not enough candidates");

        uint first = 0;
        uint second = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            uint votes = candidates[i].voteCount;
            if (votes > candidates[first].voteCount) {
                second = first;
                first = i;
            } else if (votes > candidates[second].voteCount && i != first) {
                second = i;
            }
        }

        require(second != 0, "No runner-up found");
        Candidate memory runner = candidates[second];
        return (runner.id, runner.name, runner.voteCount);
    }

    function getTopNCandidates(uint n) public view returns (Candidate[] memory) {
        require(n > 0 && n <= candidatesCount, "Invalid count");

        Candidate[] memory temp = new Candidate[](candidatesCount);
        for (uint i = 0; i < candidatesCount; i++) {
            temp[i] = candidates[i + 1];
        }

        // Bubble sort (inefficient, use only for small N)
        for (uint i = 0; i < candidatesCount; i++) {
            for (uint j = 0; j < candidatesCount - i - 1; j++) {
                if (temp[j].voteCount < temp[j + 1].voteCount) {
                    (temp[j], temp[j + 1]) = (temp[j + 1], temp[j]);
                }
            }
        }

        Candidate[] memory top = new Candidate[](n);
        for (uint i = 0; i < n; i++) {
            top[i] = temp[i];
        }
        return top;
    }

    function getCandidatesWithZeroVotes() public view returns (Candidate[] memory) {
        Candidate[] memory temp = new Candidate[](candidatesCount);
        uint count = 0;

        for (uint i = 1; i <= candidatesCount; i++) {
            Candidate memory candidate = candidates[i];
            if (candidate.voteCount == 0) {
                temp[count++] = candidate;
            }
        }

        Candidate[] memory zeroCandidates = new Candidate[](count);
        for (uint i = 0; i < count; i++) {
            zeroCandidates[i] = temp[i];
        }

        return zeroCandidates;
    }

    function getLeadingCandidates() public view returns (Candidate[] memory) {
        require(candidatesCount > 0, "No candidates");

        uint maxVotes = 0;
        uint count = 0;

        // First pass: get maxVotes and count leaders
        for (uint i = 1; i <= candidatesCount; i++) {
            uint votes = candidates[i].voteCount;
            if (votes > maxVotes) {
                maxVotes = votes;
                count = 1;
            } else if (votes == maxVotes) {
                count++;
            }
        }

        // Second pass: gather all leading candidates
        Candidate[] memory leaders = new Candidate[](count);
        uint index = 0;
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount == maxVotes) {
                leaders[index++] = candidates[i];
            }
        }

        return leaders;
    }

    // ----------- Voter Functions -----------

    function hasAddressVoted(address _voter) public view returns (bool) {
        return hasVoted[_voter];
    }

    function hasSenderVoted() public view returns (bool) {
        return hasVoted[msg.sender];
    }

    function getVotingStatuses(address[] calldata _voters) external view returns (bool[] memory) {
        uint len = _voters.length;
        bool[] memory statuses = new bool[](len);
        for (uint i = 0; i < len; i++) {
            statuses[i] = hasVoted[_voters[i]];
        }
        return statuses;
    }

    function getAllVoters() public view returns (address[] memory) {
        return voterList;
    }

    function isCandidateValid(uint _candidateId) public view returns (bool) {
        return _candidateId != 0 && _candidateId <= candidatesCount;
    }
}
