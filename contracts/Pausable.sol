pragma solidity ^0.5.0;

import "./Owner.sol";

contract Pausable is Owner {
    bool private contractPausedState;

    event ContractPausedState (bool newState, address pausedBy);
    
    modifier notPaused() {
        require (!contractPausedState, "Contract is paused");
        _;
    }

    constructor (bool initialState) public {
        contractPausedState = initialState;
    }

    function contractPaused(bool newState) public onlyOwner() {
        require(newState != contractPausedState, "Redundant request, no change made");
        contractPausedState = newState;
        emit ContractPausedState (newState, msg.sender);
    }
}