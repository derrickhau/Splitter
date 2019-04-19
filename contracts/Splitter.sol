pragma solidity ^0.5.0;

import "./Pausable.sol";

contract Splitter is Pausable {
    address payable public bob;
    address payable public carol;
    uint bobEtherAvailable;
    uint carolEtherAvailable;
    bool tieBreakerBob;
    
    event TieBreakerResult(bool tieBreakerBob);
    event SplitSuccess(uint bobEtherSplit, uint carolEtherSplit);
    event WithdrawalSent(address indexed receiver, uint indexed amountSent);

    constructor (address payable _bob, address payable _carol) public {
        require(_bob != address(0));
        require(_carol != address(0));
        bob = _bob;
        carol = _carol;
    }

    function depositFunds() public payable onlyOwner() notPaused() {
        uint bobShare;
        uint carolShare;
        uint half = msg.value / 2;
        if (msg.value % 2 != 0) {
            if (tieBreakerBob) {
                bobShare = half + 1;
                carolShare = half;
            } else {
                carolShare = half + 1;
                bobShare = half;
            }
            emit TieBreakerResult(tieBreakerBob);
            tieBreakerBob = !tieBreakerBob;
        } else {
            bobShare = half;
            carolShare = half;
        }
        assert (msg.value == bobShare + carolShare, "Split error");
        bobEtherAvailable += bobShare;
        carolEtherAvailable += carolShare;
        emit SplitSuccess(bobShare, carolShare);
    }    
    
    function bobEtherWithdrawal() public payable notPaused() {
        require(bob == msg.sender, "Restricted access, Bob only");
        require(bobEtherAvailable > 0, "Insufficient funds");
        uint bobEtherTransfer = bobEtherAvailable;
        bobEtherAvailable = 0;
        emit WithdrawalSent (bob, bobEtherTransfer);
        bob.transfer(bobEtherTransfer);
    }
    
    function carolEtherWithdrawal() public payable notPaused() {
        require(carol == msg.sender, "Restricted access, Carol only");
        require(carolEtherAvailable > 0, "Insufficient funds");
        uint carolEtherTransfer = carolEtherAvailable;
        carolEtherAvailable = 0;
        emit WithdrawalSent (carol, carolEtherTransfer);
        carol.transfer(carolEtherTransfer);
    } 
}