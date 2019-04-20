pragma solidity ^0.5.0;

import "./Pausable.sol";

contract Splitter is Pausable {
    mapping(address=>uint) public balances;

    address payable public bob;
    address payable public carol;
    bool tieBreakerBob;
    
    event TieBreakerResult(bool tieBreakerBob);
    event SplitSuccess(uint bobEtherSplit, uint carolEtherSplit);
    event WithdrawalSent(address indexed receiver, uint amount);

    constructor (address payable _bob, address payable _carol) public {
        require(_bob != address(0));
        require(_carol != address(0));
        bob = _bob;
        carol = _carol;
    }

    function depositFunds() public payable onlyOwner() notPaused() {
        uint half = msg.value / 2;
        uint bobShare = half;
        uint carolShare = half;
        if (msg.value % 2 != 0) {
            if (tieBreakerBob) { bobShare += 1; }
            else { carolShare += 1; }
            emit TieBreakerResult(tieBreakerBob);
            tieBreakerBob = !tieBreakerBob;   
        }
        require (msg.value == bobShare + carolShare, "Split error");
        balances[bob] += bobShare;
        balances[carol] += carolShare;
        emit SplitSuccess(bobShare, carolShare);
    }
    
    function withdrawal() public payable notPaused() {
        require(balances[msg.sender] > 0, "Insufficient funds");
        uint etherTransfer = balances[msg.sender];
        balances[msg.sender] = 0;
        emit WithdrawalSent (msg.sender, etherTransfer);
        msg.sender.transfer(etherTransfer);
    }
}