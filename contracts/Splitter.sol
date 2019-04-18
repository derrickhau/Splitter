pragma solidity ^0.5.0;

import "./Pausable.sol";

contract Splitter is Pausable {
    address payable public bob;
    address payable public carol;
    uint bobEtherAvailable;
    uint carolEtherAvailable;
    bool tieBreakerBob;
    
    event DepositReceived(uint indexed depositAmount);
    event TieBreakerResult(bool tieBreakerBob);
    event SplitSuccess(uint bobEtherSplit, uint carolEtherSplit);
    event WithdrawalSent(address indexed receiver, address sender, uint indexed amountSent);

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
        if (msg.value % 2 != 0) {
            if (tieBreakerBob) {
                bobEtherSplit = 1;
            } else {
                carolEtherSplit = 1;
            }
            emit TieBreakerResult(tieBreakerBob);
            tieBreakerBob = !tieBreakerBob;
        }
        bobEtherSplit += splitEther;
        carolEtherSplit += splitEther;
        require (msg.value == bobEtherSplit + carolEtherSplit, "Split error");
        bobEtherAvailable += bobEtherSplit;
        carolEtherAvailable += carolEtherSplit;
        emit SplitSuccess(bobEtherSplit, carolEtherSplit);
    }    
    
    function bobEtherWithdrawal() public payable notPaused() {
        require(bob == msg.sender, "Restricted access, Bob only");
        require(bobEtherAvailable > 0, "Insufficient funds");
        uint bobEtherTransfer = bobEtherAvailable;
        bobEtherAvailable = 0;
        emit WithdrawalSent (bob, alice, bobEtherTransfer);
        bob.transfer(bobEtherTransfer);
    }
    
    function carolEtherWithdrawal() public payable notPaused() {
        require(carol == msg.sender, "Restricted access, Carol only");
        require(carolEtherAvailable > 0, "Insufficient funds");
        uint carolEtherTransfer = carolEtherAvailable;
        carolEtherAvailable = 0;
        emit WithdrawalSent (carol, alice, carolEtherTransfer);
        carol.transfer(carolEtherTransfer);
    } 
}