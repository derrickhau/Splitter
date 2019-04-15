pragma solidity ^0.5.0;

contract Splitter {
	address payable public alice ;
	address payable public bob;
	address payable public carol;
	uint public splitEther;
	bool public locked; //false = default
	
	event TransferSuccess(address indexed receiver, address indexed sender, uint indexed amount); 

	modifier onlyAlice() {
		require (msg.sender == alice);
		_;
	}
	
    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }
    
	constructor (address payable _bob, address payable _carol) public {
		alice = msg.sender;
		bob = _bob;
		carol = _carol;
	}
	
	function () external payable onlyAlice() {
	    splitterOfEth(msg.value);
	}

    function splitterOfEth(uint aliceEther) public payable onlyAlice() noReentrancy() {
        splitEther = aliceEther / 2;
        bob.transfer(splitEther);
        emit TransferSuccess (bob, alice, splitEther); 
        carol.transfer(splitEther);
        emit TransferSuccess (carol, alice, splitEther);
    }

	function getBalance(address account) public view returns (uint) {
        return address(account).balance;
    }
}