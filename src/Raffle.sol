// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


contract Raffle is VRFConsumerBaseV2Plus {
    error Raffle_NotEnoughETHSent();

    uint16 private constant requestConfirmations = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    uint32 private immutable i_callbackGasLimit;

    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee, uint256 interval, address vrfCoordinator, bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit) 
    VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }     


    function enterRaffle() public payable{
        if (msg.value < i_entranceFee) {
            revert Raffle_NotEnoughETHSent();
        }
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {

        if((block.timestamp - s_lastTimeStamp) >= i_interval) {

            revert();

            
            VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false}) 
                )
            });

            uint256 requestId = s_vrfCoordinator.requestRandomWords(request);

    }
    // function fulfillRandomWords(uint256 requestId, uint256[] callData randomWords) internal override
    // {}
    
    }
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {}

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
        }

}
