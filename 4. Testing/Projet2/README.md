# Tests du Smart Contract de Vote

## Aperçu
Ce dépôt contient des suites de tests complets pour un smart contract de vote construit sur Ethereum. Le contrat implémente un système de vote complet avec enregistrement des électeurs, soumission des propositions, vote et dépouillement des résultats.

## Fonctionnalités Testées du Smart Contract
- Enregistrement des électeurs
- Soumission des propositions
- Mécanisme de vote
- Dépouillement des votes
- Gestion des états du workflow
- Contrôle d'accès

## Couverture des Tests

### 1. Tests de Déploiement du Contrat
- Vérification de l'état initial
- Validation de l'attribution du propriétaire

### 2. Tests d'Enregistrement des Électeurs
- Capacité du propriétaire à enregistrer les électeurs
- Enregistrement multiple d'électeurs
- Contrôle d'accès pour l'enregistrement
- Prévention des doublons d'enregistrement
- Validation des restrictions de phase
- Contrôle d'accès aux informations des électeurs

### 3. Tests d'Enregistrement des Propositions
- Vérification de la proposition Genesis
- Soumission de propositions par les électeurs enregistrés
- Soumission multiple de propositions
- Validation des propositions vides
- Contrôle d'accès pour la soumission des propositions
- Validation des restrictions de phase
- Contrôle d'accès aux informations des propositions

### 4. Tests de Session de Vote
- Mécanisme de vote
- Prévention du double vote
- Tentatives de vote sur propositions invalides
- Contrôle d'accès au vote
- Validation des restrictions de phase
- Précision du comptage des votes

### 5. Tests de Gestion du Workflow
- Progression complète du workflow
- Événements de changement d'état
- Contrôle d'accès pour les changements d'état
- Validation de la séquence des étapes
- Restrictions de transition de phase

### 6. Tests de Dépouillement
- Précision de la détermination du gagnant
- Mécanisme de gestion des égalités
- Contrôle d'accès au dépouillement
- Validation des restrictions de phase
- Vérification de l'état final

## Stack Technologique
- Solidity ^0.8.20
- Hardhat
- Ethers.js
- Chai (pour les assertions)
- Contrats OpenZeppelin

## Prérequis
- Node.js >= 14.0.0
- npm >= 6.0.0

## Installation

1. Cloner le dépôt
```bash
git clone https://github.com/Chewbaccoin/DevBlockchain-Hamilton.git
```

2. Installer les dépendances
```bash
npm install
```

3. Installer les dépendances spécifiques
```bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @openzeppelin/contracts
```

## Configuration

1. Créer ou mettre à jour votre `hardhat.config.js` :
```javascript
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
```

## Exécution des Tests

Lancer tous les tests :
```bash
npx hardhat test
```

Lancer avec rapport de gas :
```bash
REPORT_GAS=true npx hardhat test
```

## Structure des Tests

Les tests sont organisés en six sections principales :

1. **Déploiement du Contrat**
   - Vérifications basiques du déploiement
   - Vérification de l'état initial

2. **Enregistrement des Électeurs**
   - Fonctionnalité d'enregistrement
   - Contrôle d'accès
   - Cas limites

3. **Enregistrement des Propositions**
   - Soumission des propositions
   - Vérifications de validation
   - Restrictions d'accès

4. **Session de Vote**
   - Émission des votes
   - Validation des votes
   - Contrôle d'accès

5. **États du Workflow**
   - Transitions d'état
   - Gestion des phases
   - Émission d'événements

6. **Dépouillement des Votes**
   - Calcul du gagnant
   - Gestion des égalités
   - Vérification de l'état final

## Événements Testés
- `VoterRegistered`
- `WorkflowStatusChange`
- `ProposalRegistered`
- `Voted`

## Considérations de Sécurité
La suite de tests inclut la vérification de :
- Mécanismes de contrôle d'accès
- Restrictions de transition d'état
- Validation des entrées
- Prévention du double vote
- Opérations spécifiques aux phases

## Gestion des Erreurs
Les tests couvrent divers scénarios d'erreur incluant :
- Tentatives d'accès non autorisé
- Transitions d'état invalides
- Opérations en double
- Données d'entrée invalides
- Tentatives de violation de phase

## Coverage

Lancer avec rapport de coverage :
```bash
npx hardhat coverage
```

#### Rapport de Couverture de Tests

| File | % Stmts | % Branch | % Funcs | % Lines | Uncovered Lines |
|------|---------|----------|---------|---------|-----------------|
| contracts/ | 100 | 91.67 | 100 | 100 | |
| Voting.sol | 100 | 91.67 | 100 | 100 | |
| All files | 100 | 91.67 | 100 | 100 | |


#### Résumé
- **Statements**: 100% de couverture
- **Branches**: 91.67% de couverture
- **Functions**: 100% de couverture
- **Lines**: 100% de couverture

Cette couverture de test montre une excellente couverture globale du code avec :
- Une couverture complète des statements, functions et lines
- Une très bonne couverture des branches (91.67%)


## Contribution
N'hésitez pas à soumettre des issues et des demandes d'amélioration.

## Auteur
Nicolas Bellengé - Chewbaccoin
