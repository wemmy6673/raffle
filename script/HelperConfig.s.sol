// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";


abstract contract CodeConstants {
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant LOCAL_CHAIN_ID = 31337;

    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    int256 public MOCK_WEI_PER_UNIT_LINK = 4e15;
    }


contract HelperConfig is CodeConstants, Script {
    error HelperConfig_InvalidChainId();
    // This contract is a placeholder for the HelperConfig contract
    // It can be used to store configuration data for the Raffle contract
    // such as entrance fee, interval, VRF coordinator address, etc.
    
    // Add your configuration variables and functions here

    
    struct NetworkConfig { 
        uint256 entranceFee; 
        uint256 interval; 
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId; 
        uint32 callbackGasLimit;
        address link;
      
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;
    constructor(){
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainId(uint256 chainId) public returns(NetworkConfig memory) {
        
        if(networkConfigs[chainId].vrfCoordinator != address (0)){
            return networkConfigs[chainId];
        } else if(chainId == LOCAL_CHAIN_ID){

           return getOrCreateAnvilEthConfig();

        }
        else{
            revert HelperConfig_InvalidChainId();
        }
    }

    function getConfig() public returns(NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) { 
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 500000,
            subscriptionId: 66088856123678569475786979383946039100850635723923791162352989978143844289465, 
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        
});

    

}
function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory)
            {
                if (localNetworkConfig.vrfCoordinator != address(0)) {
                    return localNetworkConfig;
                }
            vm.startBroadcast();

            VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
            LinkToken linkToken = new LinkToken();

            vm.stopBroadcast();

            localNetworkConfig = NetworkConfig({

                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: address(vrfCoordinatorMock),
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                callbackGasLimit: 500000,
                subscriptionId: 0,
                link: address(linkToken)

            });
            return localNetworkConfig;
}
}