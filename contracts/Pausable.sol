pragma solidity ^0.5.0;

contract Pausable {
    bool private contractPausedState;
    address alice;

    event ContractPausedState (bool newState, address pausedBy);
    
    modifier onlyAlice() {
        require (msg.sender == alice, "Restricted access, Alice only");
        _;
    }
    modifier notPaused() {
        require (!contractPausedState);
        _;
    }
    
    constructor () public {
        alice = msg.sender;
    }

    function contractPaused(bool newState) public onlyAlice() {
        contractPausedState = newState;
        emit ContractPausedState (newState, msg.sender);
    }
}