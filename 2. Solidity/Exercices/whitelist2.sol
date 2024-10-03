// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract Whitelist {

    mapping( address => bool) whitelist;

    event Authorized( address _address);
}