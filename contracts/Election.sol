// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";

contract Election is Ownable {
    using SafeMath for uint256;
    
    // Structure représentant un candidat
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }
    
    // Mapping des candidats et compteur de candidats
    mapping(uint256 => Candidate) public candidates;
    uint256 public candidatesCount;
    
    // Mapping pour vérifier si une adresse a déjà voté
    mapping(address => bool) public voters;
    
    // Mapping pour la whitelist des adresses autorisées à ajouter des candidats
    mapping(address => bool) public whitelist;
    
    // Événements
    event CandidateAdded(uint256 candidateId, string name);
    event Voted(address voter, uint256 candidateId);
    
    // Modificateur qui restreint l'accès aux adresses présentes dans la whitelist
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Vous n'etes pas dans la whitelist");
        _;
    }
    
    // Fonctions de gestion de la whitelist (seulement accessibles par le propriétaire grâce à Ownable)
    function addToWhitelist(address _addr) public onlyOwner {
        whitelist[_addr] = true;
    }
    
    function removeFromWhitelist(address _addr) public onlyOwner {
        whitelist[_addr] = false;
    }
    
    // Fonction pour ajouter un candidat, accessible uniquement aux adresses whitelistées
    function addCandidate(string memory _name) public onlyWhitelisted {
        candidatesCount = candidatesCount.add(1);
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateAdded(candidatesCount, _name);
    }
    
    // Fonction pour voter pour un candidat
    function vote(uint256 _candidateId) public {
        // Vérifier que l'électeur n'a pas déjà voté
        require(!voters[msg.sender], "Vous avez deja vote");
        // Vérifier que le candidat existe
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Candidat invalide");
        
        // Enregistrer le vote
        voters[msg.sender] = true;
        candidates[_candidateId].voteCount = candidates[_candidateId].voteCount.add(1);
        emit Voted(msg.sender, _candidateId);
    }
    
    // Vous pouvez ajouter d'autres fonctions relatives à la gestion de l'élection si nécessaire.
}