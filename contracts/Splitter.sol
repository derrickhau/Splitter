pragma solidity ^0.5.0;

import "./Pausable.sol";

contract Splitter is Pausable {
    mapping(address=>uint) public balances;
    bool tieBreaker;
    
    event TieBreakerResult(bool tieBreaker);
    event SplitSuccess(uint recipient1Share, uint recipient2Share);
    event WithdrawalSent(address indexed receiver, uint amount);

    constructor () public {}
    
    function depositFunds(address recipient1, address recipient2) public payable onlyOwner() notPaused() {
        uint half = msg.value / 2;
        uint recipient1Share = half;
        uint recipient2Share = half;
        if (msg.value % 2 != 0) {
            if (tieBreaker) { recipient1Share += 1; }
            else { recipient2Share += 1; }
            emit TieBreakerResult(tieBreaker);
            tieBreaker = !tieBreaker;   
        }
        require (msg.value == recipient1Share + recipient2Share, "Split error");
        balances[recipient1] += recipient1Share;
        balances[recipient2] += recipient2Share;
        emit SplitSuccess(recipient1Share, recipient2Share);
    }
    
    function withdrawal() public payable notPaused() {
        require(balances[msg.sender] > 0, "Insufficient funds");
        uint etherTransfer = balances[msg.sender];
        balances[msg.sender] = 0;
        emit WithdrawalSent (msg.sender, etherTransfer);
        msg.sender.transfer(etherTransfer);
    }
}