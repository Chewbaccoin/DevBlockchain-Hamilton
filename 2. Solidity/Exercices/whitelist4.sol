// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract Whitelist {

    mapping( address => bool) whitelist;

    event Authorized( address _address);
    event EthReceived( address _addr, uint _value);

    function authorize( address _address) public {
        require ( check(), "you are not authorized");
        whitelist[ _address] = true;
        emit Authorized( _address);
    }

    function check() private view returns (bool) {
        if ( whitelist[ msg.sender] == true) 
            return true;
        return false;
    }
}