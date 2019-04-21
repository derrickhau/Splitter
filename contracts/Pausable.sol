pragma solidity ^0.5.0;

import "./Owner.sol";

contract Pausable is Owner {
    bool private contractPausedState;

    event ContractPausedState (bool newState, address pausedBy);
    
    modifier notPaused() {
        require (!contractPausedState);
        _;
    }
    
    constructor () public {
    }

    function contractPaused(bool newState) public onlyOwner() {
        require(newState != contractPausedState, "Redundant request, no change made");
        contractPausedState = newState;
        emit ContractPausedState (newState, msg.sender);
    }
}