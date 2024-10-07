// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
/// @title Formation Alyra DEV Blockchain - Promotion Hamilton - Nicolas Bellerngé @chewbaccoin - Projet 1

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    // Structure des votants 
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }

    // Structure des propositions soumises au vote
    struct Proposal {
        string description;
        uint256 voteCount;
    }

    // Statuts du cours de la procédure
    enum WorkflowStatus {
        RegisteringVoters,  
        ProposalsRegistrationStarted, 
        ProposalsRegistrationEnded, 
        VotingSessionStarted,  
        VotingSessionEnded,   
        VotesTallied          
    }

    // Variables d'état
    WorkflowStatus public workflowStatus; 
    //ID de la proposition gagante
    uint256 public winningProposalId;

    // Mappages et tableaux
    mapping(address => Voter) public voters;
    mapping(address => uint256) public publicVotes;
    Proposal[] public proposals;
    
    // Liste des evénements
    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint256 proposalId);
    event Voted (address voter, uint256 proposalId);


    // Définition du constructor, réponse à l'exigence "l'admin est celui qui déploie le contrat" => Owned by msg.sendor
    constructor() Ownable( msg.sender) {
            // Le contrat s'auto-initialise à la première valeur de l'enum WorkflowStatus : RegisteringVoters
    }

    // Définition des modifiers utiles aux différents test conditionnels du contrat
    modifier onlyWhitelisted() {
        require( voters[ msg.sender].isRegistered, unicode"[Erreur] - Vous ne faites pas partie des personnes inscrites sur la whitelist.");
        _;
    }
    
    modifier onlyDuring(WorkflowStatus _status) {
        require( workflowStatus == _status, unicode"[Erreur] - Le workflow de la procédure de vote n'est pas respecté.");
        _;
    }

    // Fonction d'ajout de votants à la whitelist par l'Admin
    function addWhitelistedVoter( address _voter) external onlyOwner {
        require( !voters[ _voter].isRegistered, unicode"[Erreur] - L'utilisateur est déjà whitelisté.");
        voters[ _voter] = Voter( true, false, 0);
        emit VoterRegistered( _voter);
    }

    // On ouvre la phase d'enregistrement des propositions
    function startProposalsRegistration() external onlyOwner onlyDuring ( WorkflowStatus.RegisteringVoters) {
        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange( WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }
    
    // Enregistrement d'une nouvelle proposition et intialisation de celle-ci à 0 (réservée aux électeurs whitelistés)
    function registerProposals( string calldata _description) external onlyWhitelisted onlyDuring ( WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push( Proposal( { description: _description, voteCount: 0 }));
        emit ProposalRegistered( proposals.length - 1);
    }

    // Cloturer la phase d'enregistrement des nouvelles propositions
    function endProposalsRegistration() external onlyOwner onlyDuring ( WorkflowStatus.ProposalsRegistrationStarted) {
        workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange( WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    // Ouvrir la phase de vote
    function startVoting() external onlyOwner onlyDuring( WorkflowStatus.ProposalsRegistrationEnded) {
        workflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange( WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotingSessionStarted);
    }

    // Enregistrement du vote d'un participant whitelisté
    function registerVote( uint256 _proposalId) external onlyWhitelisted onlyDuring ( WorkflowStatus.VotingSessionStarted) {
        require( !voters[ msg.sender].hasVoted, unicode"[Erreur] - Votre vote a déjà été comptabilisé, merci de ne pas bourrer les urnes !");
        // Mettre à jour le votant
        voters[ msg.sender].hasVoted = true;
        voters[ msg.sender].votedProposalId = _proposalId;

        // Ajouter un vote à la proposition choisie
        proposals[_proposalId].voteCount += 1;

         // Enregistrer le vote dans le mapping public
        publicVotes[ msg.sender] = _proposalId;
        emit Voted( msg.sender, _proposalId);
    }

    // Cloturer la phase de vote
    function endVoting() external onlyOwner onlyDuring ( WorkflowStatus.VotingSessionStarted) {
        workflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange( WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    // Dépouiller les votes
    function countVotes() external onlyOwner onlyDuring ( WorkflowStatus.VotingSessionEnded)  {
        uint256 highestVoteCount = 0;
        uint256[] memory tiedProposals; // Tableau pour stocker les propositions à égalité
        uint256 tiedProposalsCount = 0; // Compteur pour suivre le nombre de propositions à égalité

        for ( uint256 i = 0; i < proposals.length; i++) {
            if ( proposals[i].voteCount > highestVoteCount) {
                highestVoteCount = proposals[i].voteCount;
                winningProposalId = i;
                
                // Réinitialiser le tableau en cas de nouvelle valeur de votes plus élevée
                delete tiedProposals;
                tiedProposalsCount = 0;
                tiedProposals[ tiedProposalsCount] = i;
                tiedProposalsCount++;
            } else if ( proposals[i].voteCount == highestVoteCount) {
                tiedProposals[ tiedProposalsCount] = i;
                tiedProposalsCount++;
            }
        }

        // Gérer le cas où plusieurs propositions sont à égalité
        if ( tiedProposalsCount > 1) {
            // Par défaut, sélection de la première proposition atteignant ce nombre de votes.
            // Règle définie pour répondre au besoin de trancher par le développeur i.e : le gagnant et la première proposition à atteindre le meilleur score
            // modifiable si la communauté souhaite une autre méthode de désignation de gagnant.
            winningProposalId = tiedProposals[0];
        }
        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange( WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }

    // Récupérer la proposition gagnante
    function getElected() external view onlyDuring( WorkflowStatus.VotesTallied) returns (string memory winnerDescription, uint256 winnerVoteCount) {
        winnerDescription = proposals[ winningProposalId].description;
        winnerVoteCount = proposals[ winningProposalId].voteCount;
    }

    // Fonction pour récupérer le nombre total de propositions
    function getProposalsCount() external view returns ( uint256) {
        return proposals.length;
    }

    // Fonction pour récupérer la description d'une proposition par ID
    function getProposal(uint256 _proposalId) external view returns (string memory description, uint256 voteCount) {
        require(_proposalId < proposals.length, unicode"[Erreur] - ID de proposition invalide.");
        description = proposals[_proposalId].description;
        voteCount = proposals[_proposalId].voteCount;
    }

    // Fonction pour récupérer le vote des autres utilisateurs
    // Le vote n'est pas secret pour les utilisateurs ajoutés à la Whitelist
    // Chaque électeur peut voir les votes des autres
    function getPublicVotes() external view onlyWhitelisted returns ( address[] memory, uint256[] memory) {
        address[] memory votersAddresses = new address[]( proposals.length);
        uint256[] memory votes = new uint256[]( proposals.length);
        uint256 counter = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if ( publicVotes[ votersAddresses[i]] != 0) {
                votersAddresses[ counter] = votersAddresses[ i];
                votes[ counter] = publicVotes[ votersAddresses[ i]];
                counter++;
            }
        }
        return ( votersAddresses, votes);
    }
}
