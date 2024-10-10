// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Notation {
    
    struct Student {
        string name;
        uint noteBiology;
        uint noteMath;
        uint noteFr;
    }

    struct Teacher {
        bool isAuthorized;
    }

    address public owner;
    mapping(address => Student) public students;
    mapping(address => Teacher) public teachers;
    address[] public studentAddresses;
    
    modifier onlyOwner() {
        require(msg.sender == owner, unicode"[Erreur] - Only owner can perform this action");
        _;
    }

    modifier onlyTeacher() {
        require(teachers[msg.sender].isAuthorized, unicode"[Erreur] - Only authorized teachers can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Ajouter un élève
    function addStudent(address studentAddress, string memory _name) public onlyOwner {
        students[studentAddress] = Student(_name, 0, 0, 0);
        studentAddresses.push(studentAddress);
    }

    // Ajouter un professeur
    function addTeacher(address teacherAddress) public onlyOwner {
        teachers[teacherAddress].isAuthorized = true;
    }

    // Définir une note pour un élève
    function setNote(address studentAddress, uint _noteBiology, uint _noteMath, uint _noteFr) public onlyTeacher {
        Student storage student = students[studentAddress];
        student.noteBiology = _noteBiology;
        student.noteMath = _noteMath;
        student.noteFr = _noteFr;
    }

    // Calculer la moyenne générale d'un élève
    function getStudentAverage(address studentAddress) public view returns (uint) {
        Student memory student = students[studentAddress];
        return (student.noteBiology + student.noteMath + student.noteFr) / 3;
    }

    // Calculer la moyenne d'une matière pour toute la classe
    function getClassAverageBiology() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < studentAddresses.length; i++) {
            total += students[studentAddresses[i]].noteBiology;
        }
        return total / studentAddresses.length;
    }

    function getClassAverageMath() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < studentAddresses.length; i++) {
            total += students[studentAddresses[i]].noteMath;
        }
        return total / studentAddresses.length;
    }

    function getClassAverageFr() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < studentAddresses.length; i++) {
            total += students[studentAddresses[i]].noteFr;
        }
        return total / studentAddresses.length;
    }

    // Calculer la moyenne générale de la classe
    function getClassAverage() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < studentAddresses.length; i++) {
            total += getStudentAverage(studentAddresses[i]);
        }
        return total / studentAddresses.length;
    }

    // Vérifier si un élève a validé son année
    function hasPassed(address studentAddress) public view returns (bool) {
        return getStudentAverage(studentAddress) >= 10;
    }
}
