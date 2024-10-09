// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GuessTheWordGame is Ownable {

    // Stockage des informations nécessaires au jeu
    string private secretWord;     
    string private hint;           
    address public winner;         
    bool public gameActive;        
    
    // Liste pour garder une trace des participants
    address[] public players;

    // Mapping pour savoir qui a déjà tenté sa chance
    mapping(address => bool) public hasPlayed;

    // Événements pour signaler la victoire ou la réinitialisation du jeu
    event GameWon(address indexed winner, string word);
    event GameReset();

    // Modificateur pour s'assurer que le jeu est bien en cours
    modifier onlyWhenGameActive() {
        require(gameActive, unicode"[Erreur] - Aucun jeu actif en ce moment. Attendez qu'un nouveau jeu commence.");
        _;
    }

    constructor() Ownable(msg.sender) {
        // Le jeu démarre comme étant inactif
        gameActive = false;
    }

    // Permet à l'owner de définir le mot secret et l'indice
    function setWordAndHint(string memory _word, string memory _hint) external onlyOwner {
        require(!gameActive, unicode"[Erreur] - Un jeu est déjà en cours. Réinitialisez d'abord.");
        secretWord = _word;
        hint = _hint;
        gameActive = true;  // Le jeu devient actif
        winner = address(0);  // Réinitialisation du gagnant
        resetPlayers();  // On réinitialise la liste des joueurs
    }

    // Permet de récupérer l'indice pour le mot secret
    function getHint() external view onlyWhenGameActive returns (string memory) {
        return hint;
    }

    // Fonction pour tenter de deviner le mot
    function guess(string memory _guess) external onlyWhenGameActive returns (bool) {
        require(!hasPlayed[msg.sender], unicode"[Erreur] - Vous avez déjà joué!");

        // On enregistre la participation du joueur
        hasPlayed[msg.sender] = true;
        players.push(msg.sender);

        // Comparaison du mot deviné avec le mot secret
        if (keccak256(abi.encodePacked(_guess)) == keccak256(abi.encodePacked(secretWord))) {
            winner = msg.sender;  // Marque le gagnant
            gameActive = false;   // Fin du jeu
            emit GameWon(msg.sender, secretWord);  // Émission de l'événement de victoire
            return true;
        }

        return false;
    }

    // Retourne l'adresse du gagnant si un gagnant existe
    function getWinner() external view returns (address) {
        require(winner != address(0), unicode"[Erreur] - Pas encore de gagnant.");
        return winner;
    }

    // Permet à l'owner de réinitialiser le jeu
    function resetGame() external onlyOwner {
        require(!gameActive, unicode"[Erreur] - Un jeu est en cours. Impossible de réinitialiser.");

        // Suppression du mot secret et de l'indice
        delete secretWord;
        delete hint;
        gameActive = false;

        // Réinitialisation des joueurs
        resetPlayers();

        emit GameReset();
    }

    // Fonction privée pour remettre à zéro la liste des joueurs
    function resetPlayers() private {
        for (uint i = 0; i < players.length; i++) {
            hasPlayed[players[i]] = false;  // Réinitialise le statut de chaque joueur
        }
        delete players;  // Vide la liste des joueurs
    }
}
