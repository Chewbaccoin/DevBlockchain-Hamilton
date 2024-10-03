// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract People {

  struct Person {
      string name;
      uint age;  
  }

  Person[] public persons;
}