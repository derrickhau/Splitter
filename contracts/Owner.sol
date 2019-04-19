pragma solidity ^0.5.0;

contract Owner {
    address owner;

    modifier onlyOwner() {
        require (msg.sender == owner, "Restricted access, owner only");
        _;
    }
    
    constructor () public {
        owner = msg.sender;
    }
}