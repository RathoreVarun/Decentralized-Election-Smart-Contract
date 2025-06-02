const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Decentralized Election Smart Contract", function () {
  // Fixture to deploy the contract before each test
  async function deployElectionFixture() {
    const [owner, voter1, voter2, voter3] = await ethers.getSigners();
    const Project = await ethers.getContractFactory("Project");
    const electionName = "Test Election 2024";
    const project = await Project.deploy(electionName);
    return { project, owner, voter1, voter2, voter3, electionName };
  }

  describe("Deployment", function () {
    it("Should set correct owner and election name", async function () {
      const { project, owner, electionName } = await loadFixture(deployElectionFixture);
      expect(await project.owner()).to.equal(owner.address);
      expect(await project.electionName()).to.equal(electionName);
      expect(await project.electionStarted()).to.equal(false);
      expect(await project.candidateCount()).to.equal(0);
    });
  });

  describe("Candidate Management", function () {
    it("Should add candidates correctly", async function () {
      const { project } = await loadFixture(deployElectionFixture);
      
      await expect(project.addCandidate("Alice"))
        .to.emit(project, "CandidateAdded")
        .withArgs(1, "Alice");
      
      const candidate = await project.getCandidate(1);
      expect(candidate[1]).to.equal("Alice");
      expect(await project.candidateCount()).to.equal(1);
    });

    it("Should reject unauthorized candidate addition", async function () {
      const { project, voter1 } = await loadFixture(deployElectionFixture);
      await expect(project.connect(voter1).addCandidate("Bob"))
        .to.be.revertedWith("Only owner can perform this action");
    });
  });

  describe("Voter Registration", function () {
    it("Should register voters correctly", async function () {
      const { project, voter1 } = await loadFixture(deployElectionFixture);
      
      await expect(project.registerVoter(voter1.address))
        .to.emit(project, "VoterRegistered")
        .withArgs(voter1.address);
      
      const voterInfo = await project.getVoter(voter1.address);
      expect(voterInfo[2]).to.equal(true); // isRegistered
    });
  });

  describe("Voting Process", function () {
    async function setupElection() {
      const { project, owner, voter1, voter2 } = await loadFixture(deployElectionFixture);
      await project.addCandidate("Alice");
      await project.addCandidate("Bob");
      await project.registerVoter(voter1.address);
      await project.registerVoter(voter2.address);
      await project.startElection();
      return { project, owner, voter1, voter2 };
    }

    it("Should allow voting and count correctly", async function () {
      const { project, voter1, voter2 } = await loadFixture(setupElection);
      
      await expect(project.connect(voter1).vote(1))
        .to.emit(project, "VoteCasted")
        .withArgs(voter1.address, 1);
      
      await project.connect(voter2).vote(1);
      
      const candidate = await project.getCandidate(1);
      expect(candidate[2]).to.equal(2); // voteCount
      expect(await project.totalVotes()).to.equal(2);
    });

    it("Should prevent double voting", async function () {
      const { project, voter1 } = await loadFixture(setupElection);
      
      await project.connect(voter1).vote(1);
      await expect(project.connect(voter1).vote(2))
        .to.be.revertedWith("You have already voted");
    });
  });

  describe("Election Control", function () {
    it("Should start and end election properly", async function () {
      const { project } = await loadFixture(deployElectionFixture);
      
      await project.addCandidate("Alice");
      
      await expect(project.startElection())
        .to.emit(project, "ElectionStarted");
      expect(await project.electionStarted()).to.equal(true);
      
      await expect(project.endElection())
        .to.emit(project, "ElectionEnded");
      expect(await project.electionEnded()).to.equal(true);
    });
  });

  describe("Winner Declaration", function () {
    it("Should declare correct winner", async function () {
      const { project, voter1, voter2 } = await loadFixture(deployElectionFixture);
      
      await project.addCandidate("Alice");
      await project.addCandidate("Bob");
      await project.registerVoter(voter1.address);
      await project.registerVoter(voter2.address);
      await project.startElection();
      
      await project.connect(voter1).vote(1); // Alice
      await project.connect(voter2).vote(1); // Alice
      
      await project.endElection();
      
      const [winnerId, winnerName, voteCount] = await project.getWinner();
      expect(winnerId).to.equal(1);
      expect(winnerName).to.equal("Alice");
      expect(voteCount).to.equal(2);
    });
  });
});
