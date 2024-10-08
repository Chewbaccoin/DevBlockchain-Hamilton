// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract Whitelist {

    mapping( address => bool) whitelist;

    event Authorized( address _address);
    event EthReceived( address _addr, uint _value);

    function authorize( address _address) public {
        whitelist[ _address] = true;
        emit Authorized( _address);
    }
}