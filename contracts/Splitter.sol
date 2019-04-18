pragma solidity ^0.5.0;

contract Paused {
    bool contractPaused;
    address payable public alice;

    event ContractPaused (bool);
    
    modifier onlyAlice() {
        require (msg.sender == alice, "Restricted access, Alice only");
        _;
    }
    modifier notPaused() {
        require (!contractPaused);
        _;
    }
    
    constructor () public {
        alice = msg.sender;
    }

    function toggleContractPaused() public onlyAlice() {
        if (contractPaused == false) {
            contractPaused = true;
            emit ContractPaused (true);
        } else {
            contractPaused = false;
            emit ContractPaused (false);
        }    
    }
}

contract Splitter is Paused {
    address payable public bob;
    address payable public carol;
    uint bobEtherTotal;
    uint carolEtherTotal;
    bool tieBreakerSwitch;
    
    event DepositReceived(uint indexed depositAmount);
    event TieBreakerResult(string winner);
    event SplitSuccess(uint bobEtherSplit, uint carolEtherSplit);
    event WithdrawalSuccess(address indexed receiver, address sender, uint indexed amountReceived);

    constructor (address payable _bob, address payable _carol) public {
        require(_bob != address(0));
        bob = _bob;
        require(_carol != address(0));
        carol = _carol;
    }

    function depositFunds() public payable onlyAlice() notPaused() {
        emit DepositReceived(msg.value);
        uint bobEtherSplit;
        uint carolEtherSplit;
        uint splitEther = msg.value / 2;
        if (msg.value % 2 != 0)
            if (tieBreaker())
                bobEtherSplit = 1;
            else
                carolEtherSplit = 1;
        bobEtherSplit += splitEther;
        carolEtherSplit += splitEther;
        require (msg.value == bobEtherSplit + carolEtherSplit, "Split error");
        bobEtherTotal += bobEtherSplit;
        carolEtherTotal += carolEtherSplit;
        emit SplitSuccess(bobEtherSplit, carolEtherSplit);
    }
    
    function bobEtherWithdrawal() public payable notPaused() {
        require(bob == msg.sender, "Restricted access, Bob only");
        require(bobEtherTotal > 0, "Insufficient funds");
        emit WithdrawalSuccess (bob, alice, bobEtherTotal);
        bob.transfer(bobEtherTotal);
        bobEtherTotal = 0;
    }
    
    function carolEtherWithdrawal() public payable notPaused() {
        require(carol == msg.sender, "Restricted access, Carol only");
        require(carolEtherTotal > 0, "Insufficient funds");
        emit WithdrawalSuccess (carol, alice, carolEtherTotal);
        carol.transfer(carolEtherTotal);
        carolEtherTotal = 0;
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
}