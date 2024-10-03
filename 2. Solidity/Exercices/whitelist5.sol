// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract Whitelist {

    mapping( address => bool) whitelist;

    event Authorized( address _address);
    event EthReceived( address _addr, uint _value);

    constructor() {
        whitelist[ msg.sender] = true;
    }

    modifier check() {
        require( whitelist[msg.sender] == true, "you are not authorized");
        _;
    }

    function authorize( address _address) public check {
        whitelist[ _address] = true;
        emit Authorized( _address);
    }

}