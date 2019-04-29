pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Pausable.sol";

contract Splitter is Pausable {
    using SafeMath for uint;    

    mapping(address => uint) public balances;
    
    event LogSplitFunds(address indexed sender, uint amount, address indexed recipient1, address indexed recipient2);
    event LogWithdrawalSent(address indexed receiver, uint amount);

    constructor (bool paused) Pausable(paused) public {}
    
    function splitFunds(address recipient1, address recipient2) public payable notPaused() {
        uint half = msg.value.div(2);
        uint remainder = msg.value.mod(2);
        balances[msg.sender] = balances[msg.sender].add(remainder);
        balances[recipient1] = balances[recipient1].add(half);
        balances[recipient2] = balances[recipient2].add(half);
        emit LogSplitFunds(msg.sender, msg.value, recipient1, recipient2);
    }
    
    function withdrawa() public notPaused() {
        uint amountDue = balances[msg.sender];
        require(amountDue > 0, "Insufficient funds");
        balances[msg.sender] = 0;
        emit LogWithdrawalSent(msg.sender, amountDue);
        msg.sender.transfer(amountDue);
    }
}