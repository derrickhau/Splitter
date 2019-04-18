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
	bool tieBreakerSwitch;
    
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
    
    constructor () public {
        alice = msg.sender;
        bob = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        require(bob != address(0));
        carol = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
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
            if (tieBreaker())
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
    
    function tieBreaker() private returns (bool){
        if (tieBreakerSwitch) {
            emit TieBreakerResult("Bob");
            tieBreakerSwitch = false;
            return true;
        } else {
            emit TieBreakerResult("Carol");
            tieBreakerSwitch = true;
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