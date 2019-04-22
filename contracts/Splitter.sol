pragma solidity ^0.5.0;

import "./Pausable.sol";

contract Splitter is Pausable {
    mapping(address=>uint) public balances;
    bool tieBreaker;
    
    event TieBreakerResult(bool tieBreaker);
    event LogSplitFunds(address sender, uint amount, address recipient1, address recipient2);
    event WithdrawalSent(address indexed receiver, uint amount);

    constructor () public {}
    
    function splitFunds(address recipient1, address recipient2) public payable onlyOwner() notPaused() {
        uint half = msg.value / 2;
        if(msg.value % 2 > 0) balances[msg.sender] ++;
        balances[recipient1] += half;
        balances[recipient2] += half;
        emit LogSplitFunds(msg.sender, msg.value, recipient1, recipient2);
    }
    
    function withdrawal() public payable notPaused() {
        require(balances[msg.sender] > 0, "Insufficient funds");
        uint etherTransfer = balances[msg.sender];
        balances[msg.sender] = 0;
        emit WithdrawalSent (msg.sender, etherTransfer);
        msg.sender.transfer(etherTransfer);
    }
}