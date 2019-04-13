pragma solidity ^0.5.0;

contract Splitter {
	address payable public alice;
	address payable public bob;
	address payable public carol;
	
	event transferSuccess(address receiver, uint amount); 

	constructor (address payable _alice, address payable _bob, address payable _carol) public payable {
		alice = _alice;
		bob = _bob;
		carol = _carol;
	}

	modifier onlyAlice() {
		require (msg.sender == alice);
		_;
	}

	function getBalance (address account) public view returns(uint) {
		uint balance = getBalance(account);
		return balance; 
	}
	
    function splitterOfEth(uint aliceEther) public payable onlyAlice() {
        uint splitEther = aliceEther / 2;
        bob.transfer(splitEther);
        emit transferSuccess (bob, splitEther); 
        carol.transfer(splitEther / 2);
        emit transferSuccess (carol, splitEther); 
    }
}