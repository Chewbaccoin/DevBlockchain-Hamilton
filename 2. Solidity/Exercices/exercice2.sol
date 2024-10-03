// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract People {
    
   struct Person {
       string name;
       uint age;   
   }
   
   Person public moi;

   function modifyPerson( string memory _name, uint _age) public {
        moi.name = _name;
        moi.age = _age;
   }
}
