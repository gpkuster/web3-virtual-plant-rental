// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "forge-std/Script.sol";
import {PlantRentalContract} from "../src/PlantRentalContract.sol";

/**
 * @title DeployPlantRental
 * @dev Foundry deployment script for the PlantRentalContract.
 *
 * 🧰 Environment Variables Required:
 *   - PRIVATE_KEY: Private key of the deployer wallet.
 *   - RPC_URL: RPC endpoint for your target network (e.g. Sepolia or Mainnet).
 *   - ETHERSCAN_API_KEY: API key for Etherscan or the relevant explorer.
 *
 * 💻 Usage:
 *   export PRIVATE_KEY=0xYOURPRIVATEKEY
 *   export RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
 *   export ETHERSCAN_API_KEY=your_etherscan_api_key
 *
 * 🔹 Dry run (simulation only):
 *   forge script script/DeployPlantRental.s.sol:DeployPlantRental --rpc-url $RPC_URL
 *
 * 🔹 Deploy & Verify (actual broadcast + verification):
 *   forge script script/DeployPlantRental.s.sol:DeployPlantRental \
 *       --rpc-url $RPC_URL \
 *       --broadcast \
 *       --verify \
 *       -vvvv
 */
contract DeployPlantRental is Script {
    function run() external returns (PlantRentalContract) {
        // Read private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions using deployer's key
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the PlantRentalContract
        PlantRentalContract plantRental = new PlantRentalContract();

        vm.stopBroadcast();

        return plantRental;
    }
}
