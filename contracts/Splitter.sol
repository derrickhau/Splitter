pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./Pausable.sol";

contract Splitter is Pausable {
    using SafeMath for uint;    

    mapping(address => uint) public balances;

    event LogSplitFunds(address indexed sender, uint amount, address indexed recipient1, address indexed recipient2);
    event LogWithdrawalSent(address indexed receiver, uint amount);

    constructor () public {}
    
    function splitFunds(address recipient1, address recipient2) public payable notPaused() {
        uint half = SafeMath.div(msg.value, 2);
        uint remainder = SafeMath.mod(msg.value, 2);
        if(remainder > 1) balances[msg.sender] += remainder;
        balances[recipient1] = SafeMath.add(balances[recipient1], half);
        balances[recipient2] = SafeMath.add(balances[recipient2], half);
        emit LogSplitFunds(msg.sender, msg.value, recipient1, recipient2);
    }
    
    function withdrawal() public notPaused() {
        uint amountDue = balances[msg.sender];
        require(amountDue > 0, "Insufficient funds");
        balances[msg.sender] = 0;
        emit LogWithdrawalSent(msg.sender, amountDue);
        msg.sender.transfer(amountDue);
    }
}