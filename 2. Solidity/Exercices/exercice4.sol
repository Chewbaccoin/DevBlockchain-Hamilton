// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract People {
 struct Person {
     string name;
     uint age; 
 }
 Person[] public persons;

 function add( string memory _name, uint _age) public {
      persons.push( Person(_name, _age));
 }
  function remove() public {
      persons.pop();
 }
}