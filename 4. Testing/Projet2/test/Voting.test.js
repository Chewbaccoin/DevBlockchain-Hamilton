const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Voting", function () {
    let votingContract;
    let owner;
    let voter1;
    let voter2;
    let voter3;
    let nonVoter;
    let voters;
    let nonVoters;

    beforeEach(async function () {
        // Get signers
        [owner, voter1, voter2, voter3, nonVoter, ...voters] = await ethers.getSigners();
        nonVoters = voters.slice(5); // Garde quelques adresses pour les non-votants

        // Deploy contract
        const VotingContract = await ethers.getContractFactory("Voting");
        votingContract = await VotingContract.deploy();
        await votingContract.waitForDeployment();
    });

    describe("Contract Deployment", function () {
        it("should deploy with correct initial state", async function () {
            expect(await votingContract.workflowStatus()).to.equal(0); // RegisteringVoters
            expect(await votingContract.winningProposalID()).to.equal(0);
        });

        it("should set the correct owner", async function () {
            expect(await votingContract.owner()).to.equal(owner.address);
        });
    });

    describe("Voter Registration", function () {
        it("should allow owner to register a voter", async function () {
            await expect(votingContract.addVoter(voter1.address))
                .to.emit(votingContract, "VoterRegistered")
                .withArgs(voter1.address);

            const voter = await votingContract.connect(voter1).getVoter(voter1.address);
            expect(voter.isRegistered).to.be.true;
            expect(voter.hasVoted).to.be.false;
            expect(voter.votedProposalId).to.equal(0);
        });

        it("should allow owner to register multiple voters", async function () {
            for (let i = 0; i < 3; i++) {
                await votingContract.addVoter(voters[i].address);
                const voter = await votingContract.connect(voters[i]).getVoter(voters[i].address);
                expect(voter.isRegistered).to.be.true;
            }
        });

        it("should revert when non-owner tries to register a voter", async function () {
            await expect(votingContract.connect(voter1).addVoter(voter2.address))
                .to.be.revertedWithCustomError(votingContract, "OwnableUnauthorizedAccount");
        });

        it("should revert when registering an already registered voter", async function () {
            await votingContract.addVoter(voter1.address);
            await expect(votingContract.addVoter(voter1.address))
                .to.be.revertedWith("Already registered");
        });

        it("should revert when trying to register voter after registration phase", async function () {
            await votingContract.startProposalsRegistering();
            await expect(votingContract.addVoter(voter1.address))
                .to.be.revertedWith("Voters registration is not open yet");
        });

        it("should only allow registered voters to get voter info", async function () {
            await votingContract.addVoter(voter1.address);
            await expect(votingContract.connect(nonVoter).getVoter(voter1.address))
                .to.be.revertedWith("You're not a voter");
        });
    });

    describe("Proposal Registration", function () {
        beforeEach(async function () {
            await votingContract.addVoter(voter1.address);
            await votingContract.addVoter(voter2.address);
            await votingContract.startProposalsRegistering();
        });

        it("should initialize with GENESIS proposal", async function () {
            const genesisProposal = await votingContract.connect(voter1).getOneProposal(0);
            expect(genesisProposal.description).to.equal("GENESIS");
            expect(genesisProposal.voteCount).to.equal(0);
        });

        it("should allow registered voter to add proposal", async function () {
            await expect(votingContract.connect(voter1).addProposal("Proposal 1"))
                .to.emit(votingContract, "ProposalRegistered")
                .withArgs(1);

            const proposal = await votingContract.connect(voter1).getOneProposal(1);
            expect(proposal.description).to.equal("Proposal 1");
            expect(proposal.voteCount).to.equal(0);
        });

        it("should allow multiple proposals from the same voter", async function () {
            await votingContract.connect(voter1).addProposal("Proposal 1");
            await votingContract.connect(voter1).addProposal("Proposal 2");
            
            const proposal1 = await votingContract.connect(voter1).getOneProposal(1);
            const proposal2 = await votingContract.connect(voter1).getOneProposal(2);
            
            expect(proposal1.description).to.equal("Proposal 1");
            expect(proposal2.description).to.equal("Proposal 2");
        });

        it("should revert when non-registered voter tries to add proposal", async function () {
            await expect(votingContract.connect(nonVoter).addProposal("Proposal"))
                .to.be.revertedWith("You're not a voter");
        });

        it("should revert with empty proposal", async function () {
            await expect(votingContract.connect(voter1).addProposal(""))
                .to.be.revertedWith("Vous ne pouvez pas ne rien proposer");
        });

        it("should revert when trying to add proposal before registration starts", async function () {
            const VotingContract = await ethers.getContractFactory("Voting");
            const newVotingContract = await VotingContract.deploy();
            await newVotingContract.waitForDeployment();
            
            await newVotingContract.addVoter(voter1.address);
            await expect(newVotingContract.connect(voter1).addProposal("Proposal"))
                .to.be.revertedWith("Proposals are not allowed yet");
        });

        it("should only allow registered voters to get proposal info", async function () {
            await votingContract.connect(voter1).addProposal("Proposal 1");
            await expect(votingContract.connect(nonVoter).getOneProposal(1))
                .to.be.revertedWith("You're not a voter");
        });
    });

    describe("Voting Session", function () {
        beforeEach(async function () {
            // Setup complete voting environment
            await votingContract.addVoter(voter1.address);
            await votingContract.addVoter(voter2.address);
            await votingContract.startProposalsRegistering();
            await votingContract.connect(voter1).addProposal("Proposal 1");
            await votingContract.connect(voter2).addProposal("Proposal 2");
            await votingContract.endProposalsRegistering();
            await votingContract.startVotingSession();
        });

        it("should allow registered voter to vote", async function () {
            await expect(votingContract.connect(voter1).setVote(1))
                .to.emit(votingContract, "Voted")
                .withArgs(voter1.address, 1);

            const voter = await votingContract.connect(voter1).getVoter(voter1.address);
            expect(voter.hasVoted).to.be.true;
            expect(voter.votedProposalId).to.equal(1);

            const proposal = await votingContract.connect(voter1).getOneProposal(1);
            expect(proposal.voteCount).to.equal(1);
        });

        it("should revert when voter tries to vote twice", async function () {
            await votingContract.connect(voter1).setVote(1);
            await expect(votingContract.connect(voter1).setVote(1))
                .to.be.revertedWith("You have already voted");
        });

        it("should revert when voting for non-existent proposal", async function () {
            await expect(votingContract.connect(voter1).setVote(99))
                .to.be.revertedWith("Proposal not found");
        });

        it("should revert when non-registered voter tries to vote", async function () {
            await expect(votingContract.connect(nonVoter).setVote(1))
                .to.be.revertedWith("You're not a voter");
        });

        it("should revert when trying to vote before voting session starts", async function () {
            const VotingContract = await ethers.getContractFactory("Voting");
            const newVotingContract = await VotingContract.deploy();
            await newVotingContract.waitForDeployment();
            
            await newVotingContract.addVoter(voter1.address);
            await expect(newVotingContract.connect(voter1).setVote(0))
                .to.be.revertedWith("Voting session havent started yet");
        });
    });

    describe("Workflow Status Management", function () {
        beforeEach(async function () {
            await votingContract.addVoter(voter1.address);
        });

        it("should allow complete workflow progression", async function () {
            // Start proposals registering
            await expect(votingContract.startProposalsRegistering())
                .to.emit(votingContract, "WorkflowStatusChange")
                .withArgs(0, 1);
            expect(await votingContract.workflowStatus()).to.equal(1);

            // End proposals registering
            await expect(votingContract.endProposalsRegistering())
                .to.emit(votingContract, "WorkflowStatusChange")
                .withArgs(1, 2);
            expect(await votingContract.workflowStatus()).to.equal(2);

            // Start voting session
            await expect(votingContract.startVotingSession())
                .to.emit(votingContract, "WorkflowStatusChange")
                .withArgs(2, 3);
            expect(await votingContract.workflowStatus()).to.equal(3);

            // End voting session
            await expect(votingContract.endVotingSession())
                .to.emit(votingContract, "WorkflowStatusChange")
                .withArgs(3, 4);
            expect(await votingContract.workflowStatus()).to.equal(4);
        });

        it("should prevent non-owner from changing workflow status", async function () {
            await expect(votingContract.connect(voter1).startProposalsRegistering())
                .to.be.revertedWithCustomError(votingContract, "OwnableUnauthorizedAccount");
        });

        it("should prevent skipping workflow steps", async function () {
            await expect(votingContract.endProposalsRegistering())
                .to.be.revertedWith("Registering proposals havent started yet");

            await expect(votingContract.startVotingSession())
                .to.be.revertedWith("Registering proposals phase is not finished");

            await expect(votingContract.endVotingSession())
                .to.be.revertedWith("Voting session havent started yet");
        });
    });

    describe("Vote Tallying", function () {
        beforeEach(async function () {
            // Complete setup with multiple votes
            await votingContract.addVoter(voter1.address);
            await votingContract.addVoter(voter2.address);
            await votingContract.addVoter(voter3.address);
            await votingContract.startProposalsRegistering();
            await votingContract.connect(voter1).addProposal("Proposal 1");
            await votingContract.connect(voter2).addProposal("Proposal 2");
            await votingContract.endProposalsRegistering();
            await votingContract.startVotingSession();
            await votingContract.connect(voter1).setVote(1);
            await votingContract.connect(voter2).setVote(1);
            await votingContract.connect(voter3).setVote(2);
            await votingContract.endVotingSession();
        });

        it("should correctly tally votes and determine winner", async function () {
            await votingContract.tallyVotes();
            expect(await votingContract.winningProposalID()).to.equal(1);
            
            const winningProposal = await votingContract.connect(voter1).getOneProposal(1);
            expect(winningProposal.voteCount).to.equal(2);
        });

        it("should handle tie votes by selecting the first proposal", async function () {
            // Deploy new contract for tie scenario
            const VotingContract = await ethers.getContractFactory("Voting");
            const tieVotingContract = await VotingContract.deploy();
            await tieVotingContract.waitForDeployment();

            // Setup tie voting scenario
            await tieVotingContract.addVoter(voter1.address);
            await tieVotingContract.addVoter(voter2.address);
            await tieVotingContract.startProposalsRegistering();
            await tieVotingContract.connect(voter1).addProposal("Proposal 1");
            await tieVotingContract.connect(voter2).addProposal("Proposal 2");
            await tieVotingContract.endProposalsRegistering();
            await tieVotingContract.startVotingSession();
            await tieVotingContract.connect(voter1).setVote(1);
            await tieVotingContract.connect(voter2).setVote(2);
            await tieVotingContract.endVotingSession();
            await tieVotingContract.tallyVotes();

            // First proposal should win in case of tie
            expect(await tieVotingContract.winningProposalID()).to.equal(1);
        });

        it("should revert if non-owner tries to tally votes", async function () {
            await expect(votingContract.connect(voter1).tallyVotes())
                .to.be.revertedWithCustomError(votingContract, "OwnableUnauthorizedAccount");
        });

        it("should revert if trying to tally votes before voting session is ended", async function () {
            const VotingContract = await ethers.getContractFactory("Voting");
            const newVotingContract = await VotingContract.deploy();
            await newVotingContract.waitForDeployment();

            await expect(newVotingContract.tallyVotes())
                .to.be.revertedWith("Current status is not voting session ended");
        });

        it("should set final workflow status after tallying", async function () {
            await votingContract.tallyVotes();
            expect(await votingContract.workflowStatus()).to.equal(5); // VotesTallied
        });
    });
});