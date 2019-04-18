pragma solidity ^0.5.0;

contract Splitter {
	address payable public alice;
	address payable public bob;
	address payable public carol;
	uint bobEtherTotal;
	uint carolEtherTotal;
	bool bobEtherLocked;
	bool carolEtherLocked;
	bool contractPaused;
	uint tieBreakerCounter;
    
    event DepositReceived(uint indexed depositAmount);
    event TieBreakerResult(string winner);
    event SplitSuccess(uint bobEtherSplit, bool bobEtherLocked, uint carolEtherSplit, bool carolEtherLocked);
	event WithdrawalSuccess(address indexed receiver, address sender, uint indexed amountReceived);
	event ContractPaused (bool);
    
	modifier onlyAlice() {
		require (msg.sender == alice);
		_;
	}
	
	modifier onlyEvenDeposit() {
        require(msg.value % 2 == 0, "Please use even value");
        _;
	}
    
    modifier notPaused {
        require (contractPaused == false);
        _;
    }
    
	constructor (address payable _bob, address payable _carol) public {
		alice = msg.sender;
		bob = _bob;
		require(bob != address(0));
		carol = _carol;
		require(carol != address(0));
	}
	
	function depositFunds() public payable onlyAlice() {
	    emit DepositReceived(msg.value);
	    splitterOfEth(msg.value);
    }

    function splitterOfEth(uint aliceEther) private onlyAlice() notPaused() {
        uint bobEtherSplit;
        uint carolEtherSplit;
        uint splitEther = aliceEther / 2;
        if (splitEther * 2 != aliceEther)
            if (tieBreakerBob())
                bobEtherSplit += 1;
            else
                carolEtherSplit += 1;
        bobEtherSplit += splitEther;
        carolEtherSplit += splitEther;
        require (aliceEther == bobEtherSplit + carolEtherSplit, "Split error, accounts are locked");
        bobEtherTotal += bobEtherSplit;
        carolEtherTotal += carolEtherSplit;
        bobEtherLocked = false;
        carolEtherLocked = false;
	    emit SplitSuccess(bobEtherSplit, bobEtherLocked, carolEtherSplit, carolEtherLocked);
    }
    
    function tieBreakerBob() private returns (bool){
        tieBreakerCounter += 1;
        if (tieBreakerCounter % 2 == 0) {
            emit TieBreakerResult("Bob");
            return true;
        } else {
            emit TieBreakerResult("Carol");
            return false;
        }
    }
    
    function bobEtherWithdrawal() public payable notPaused() returns (bool success) {
        require(bob == msg.sender, "Restricted access, Bob only");
        require(bobEtherTotal > 0, "Insufficient funds");
        require(!bobEtherLocked, "Access locked until successful deposit is complete");
        bobEtherLocked = true;
        bobEtherTotal = 0;
        bob.transfer(bobEtherTotal);
        emit WithdrawalSuccess (bob, alice, bobEtherTotal);
        return true;
    }
    
    function carolEtherWithdrawal() public payable notPaused() returns (bool success){
        require(carol == msg.sender, "Restricted access, Carol only");
        require(carolEtherTotal > 0, "Insufficient funds");
        require(!carolEtherLocked, "Access locked until successful deposit is complete");
        carolEtherLocked = true;
        carolEtherTotal = 0;
        carol.transfer(carolEtherTotal);
        emit WithdrawalSuccess (carol, alice, carolEtherTotal);
        return true;
    }    
        
    function toggleContractPaused() public onlyAlice {
        if (contractPaused == false) {
            contractPaused = true;
            emit ContractPaused (true);
        } else {
            contractPaused = false;
            emit ContractPaused (false);
        }    
    }
}