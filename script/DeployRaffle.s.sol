// SDPX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";

contract DeployRaffle is Script {

    function deployContract() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if(config.subscriptionId == 0){
            // create subscription
            CreateSubscription icreateSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = icreateSubscription.createSubscription(config.vrfCoordinator);

            // Fund it!
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.link);
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.subscriptionId,
            config.gasLane,
            config.callbackGasLimit,
            config.vrfCoordinator
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        // don't need to broadcast because in add consumer we already have vm.startBroadcast();
        addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.subscriptionId);
        return (raffle, helperConfig);
    }

    // Here the deploycontract still works because im calling it. With run() as empty
    function run() public {
        // deployContract();
        // Aim for 100 % tests
    }
}
