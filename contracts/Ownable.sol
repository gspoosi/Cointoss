// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;

contract Ownable {
    address internal owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }
}