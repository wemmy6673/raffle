//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {

        HelperConfig helperconfig = new HelperConfig();
        address vrfCoordinator = helperconfig.getConfig().vrfCoordinator;
        (uint256 subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);


    }

    function createSubscription(address vrfCoordinator) public returns (uint256, address){

        console.log("Creating subscription on chain Id: ", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in the HelperConfig.s.sol contract");
        return (subId, vrfCoordinator);

    }


    function run() public {
        createSubscriptionUsingConfig();
    }


    


}

contract FundSubscription is Script, CodeConstants {

    uint256 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionsUsingConfig() public {
        HelperConfig helperconfig = new HelperConfig();
        address vrfCoordinator = helperconfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperconfig.getConfig().subscriptionId;
        address link = helperconfig.getConfig().link;
        fundSubscription(vrfCoordinator, subscriptionId, link);
        
    }

    function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken) public {

        console.log("Funding subscription", subscriptionId);
        console.log("Using VRF Coordinator at ", vrfCoordinator);
        console.log("on chain Id: ", block.chainid);

        if(block.chainid == LOCAL_CHAIN_ID){

            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT * 100);
            vm.stopBroadcast();

            
        }
        else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
            vm.stopBroadcast();
        }


    }

    function run () public {

        fundSubscriptionsUsingConfig();
    }

    }

    contract AddConsumer is Script {

        function addConsumerUsingconfig(address mostRecentlyDeployed) public {
            HelperConfig helperConfig = new HelperConfig();
            uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
            address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
            addConsumer(mostRecentlyDeployed, vrfCoordinator, subscriptionId);
        }

        function addConsumer(address contractToAddToVrf, address vrfCoordinator, uint256 subscriptionId) public {

            console.log("Adding consumer Contract: ", contractToAddToVrf);
            console.log("To VRF Coordinator: ", vrfCoordinator);
            console.log("on chain Id: ", block.chainid);

            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subscriptionId, contractToAddToVrf);
            vm.stopBroadcast();

            console.log("Consumer added: ", contractToAddToVrf);
        }

        function run () external {

            address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
                "Raffle",
                block.chainid
            );

            addConsumerUsingconfig(mostRecentlyDeployed);


        }
    }