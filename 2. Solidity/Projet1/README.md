# Alyra - Développeur Blockchain - Promotion Hamilton
## Projet 1

![Logo](https://teachizy-prod.s3.fr-par.scw.cloud/eb9f009ea2ab9914fc5333e5130cd4ae/59b514174bffe4ae402b3d63aad79fe0/7548f80f88cc49c84bc1c89c502e9ced.jpg)

### Mon travail : 

#### Premier smart contract : 
* L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
* L'administrateur du vote commence la session d'enregistrement des propositions.
* Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
* L'administrateur du vote met fin à la session d'enregistrement des propositions.
* L'administrateur du vote commence la session de vote.
* Les électeurs inscrits votent pour leur proposition préférée.
* L'administrateur du vote met fin à la session de vote.
* L'administrateur du vote comptabilise les votes.
* Tout le monde peut vérifier les derniers détails de la proposition gagnante.

➡️ [Voting.sol](https://github.com/Chewbaccoin/DevBlockchain-Hamilton/blob/main/2.%20Solidity/Projet1/Voting.sol) : déployé sur Ethereum Holesky à l'adresse suivante : 
https://holesky.etherscan.io/address/0xEb3Ff43d9312f2938a84aE36b62D8189A68dd4e1#code

#### Second smart contract : 

Ajout de fonctionnalités optionnelles :  
Des méthodes ont été ajoutées pour faciliter la construction d'une interface utilisateur (UI) de site web, avec des fonctionnalités permettant de détailler le processus de vote en cours.

* `getProposalsCount()` : Renvoie le nombre total de propositions ouvertes au vote.
* `getProposal()` : Renvoie la description et le nombre de votes reçus pour une proposition donnée.
* `getProposalsRanking()` : Renvoie le classement des propositions par nombre de votes (utile pour afficher à la communauté le classement du vote en temps réel).

➡️ [VotingPlus.sol](https://github.com/Chewbaccoin/DevBlockchain-Hamilton/blob/main/2.%20Solidity/Projet1/VotingPlus.sol) : déployé sur Ethereum Holesky à l'adresse suivante : 
https://holesky.etherscan.io/address/0xf044a8071e600c165bc8a596c8f0be2c7f115240#code

