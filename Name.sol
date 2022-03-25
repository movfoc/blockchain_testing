// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.25;
/**
 * @title Name
 * @dev Store & retrieve value in a variable
 */
contract Name
{
    string Stored_name;
    //string networkName;
    address owner;

    constructor() public
    {
        Stored_name = "Hello";
        //networkName="";
        owner = msg.sender; 
    }
    function getName() external view returns (string memory)
    {
        return Stored_name;
    }
    function setName(string _setName) external 
    {
        Stored_name = _setName;
    }
    function getOwnerBalance() constant public returns (uint) {
        return owner.balance;
    }
 
}