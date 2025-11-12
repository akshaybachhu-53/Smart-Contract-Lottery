// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title A  Raffle Contract
 * @author Bachhu Akshay
 * @notice This contract is for creating a raffle
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle {
    // Errors
    error Raffle__SendMoreToEnterRaffle();

    uint256 private immutable i_entranceFee;
    /// @dev The duration of lottery in seconds.
    uint256 private immutable i_interval;
    address[] private s_players;
    uint256 private s_lastTimeStamp;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        s_players.push(payable(msg.sender)); // ETH to winner
    }

    function pickWinner() external {
        // Check to see if enough time is passed.
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert();
        }
    }

    /**
     * Getter Functions
     */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    // Layout of contracts:
    // version
    // imports
    // errors
    // interfaces, libraries, contracts
    // Type declarations
    // State variables
    // Events
    // Modifiers
    // Functions

    //Layout of Functions:
    // constructor
    // receive function
    // fallback
    // external
    // public
    // internal
    // private
    // view & pure functions
}
