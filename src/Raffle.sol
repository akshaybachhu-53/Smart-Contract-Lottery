// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title A  Raffle Contract
 * @author Bachhu Akshay
 * @notice This contract is for creating a raffle
 * @dev Implements Chainlink VRFv2.5
 */

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

error Raffle__SendMoreToEnterRaffle();

contract Raffle is VRFConsumerBaseV2Plus {
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit = 100_000;
    uint16 constant REQUEST_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;
    uint256 private s_randomWord;
    uint256 private s_requestId;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    constructor(
        uint256 entranceFee,
        uint256 interval,
        uint256 subscriptionId,
        bytes32 keyHash,
        uint32 callbackGasLimit,
        address vrfCoordinator
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
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
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyHash,
            subId: i_subscriptionId,
            requestConfirmations: REQUEST_CONFIRMATIONS,
            callbackGasLimit: i_callbackGasLimit,
            numWords: NUM_WORDS,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
        });
        s_requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        s_randomWord = randomWords[0];
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
