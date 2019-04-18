pragma solidity ^0.5.0;

contract Paused {
    bool contractPaused;
    address payable alice;

    event ContractPaused (bool);
    
    modifier onlyAlice {
        require (msg.sender == alice, "Restricted access to Alice");
        _;
    }
    modifier notPaused {
        require (!contractPaused);
        _;
    }
    
    constructor () public {
        alice = msg.sender;
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

contract Splitter is Paused {
    address payable public alice;
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
        bob = _bob;
        require(bob != address(0));
        carol = _carol;
        require(carol != address(0));
    }
    
    function depositFunds() public payable onlyAlice() {
        emit DepositReceived(msg.value);
        splitterOfEth(msg.value);
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

    function splitterOfEth(uint aliceEther) private onlyAlice() notPaused() {
        uint bobEtherSplit;
        uint carolEtherSplit;
        uint splitEther = aliceEther / 2;
        if (splitEther * 2 != aliceEther)
            if (tieBreaker())
                bobEtherSplit = 1;
            else
                carolEtherSplit = 1;
        bobEtherSplit += splitEther;
        carolEtherSplit += splitEther;
        require (aliceEther == bobEtherSplit + carolEtherSplit, "Split error, accounts are locked");
        bobEtherTotal += bobEtherSplit;
        carolEtherTotal += carolEtherSplit;
        emit SplitSuccess(bobEtherSplit, carolEtherSplit);
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