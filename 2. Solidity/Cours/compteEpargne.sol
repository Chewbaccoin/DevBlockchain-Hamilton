// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SavingsAccount is Ownable {
    uint256 public firstDepositTime;
    bool public hasDeposited;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(uint256 => Deposit) public deposits;
    uint256 public depositCounter;

    event DepositMade(uint256 amount, uint256 timestamp);

    constructor() {
        hasDeposited = false;
        depositCounter = 0;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        if (!hasDeposited) {
            firstDepositTime = block.timestamp;
            hasDeposited = true;
        }

        deposits[depositCounter] = Deposit(msg.value, block.timestamp);
        depositCounter++;

        emit DepositMade(msg.value, block.timestamp);
    }

    function withdraw() external onlyOwner {
        require(hasDeposited, "No deposit has been made");
        require(block.timestamp >= firstDepositTime + 90 days, "Funds can only be withdrawn after 3 months");
        payable(owner()).transfer(address(this).balance);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

