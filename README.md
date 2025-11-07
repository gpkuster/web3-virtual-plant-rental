# 🌿 PlantRentalContract
Hello world! Here's my first simple Solidity smart contract that allows users **to rent virtual plants** for a limited time, with daily fees and automatic expiring control.

## ⚙️ Tech Stack

- **Solidity 0.8.29**
- **Foundry** (`forge`, `cast`, `anvil`)
- **Etherscan verification**
- **Sepolia Testnet**

## 🌟 Features
- Virtual plant varieties management (`Cactus`, `Bamboo`, `Monstera`).
- Plant rental for a limited amount of days.
- Automatic expiration of the lease based on `block.timestamp`.
- Action restrictions using modifiers.
- Emits events when a plant is rented
- Efficient availability logic

## ‼️ Deployment
This contract is deployed and verified on Sepolia testnet at this address: [0xA299086F216442FAc46f4b009b88827a371043E6](https://sepolia.etherscan.io/address/0xA299086F216442FAc46f4b009b88827a371043E6)

If you want to deploy it yourself, you need to add the following environment variables in a `.env` file on the project's root:

### 🔐 Environment Variables (`.env`)

```env
PRIVATE_KEY=0x<your_metamask_private_key> // you need ETH Sepolia, which you can get for free at some faucet
ETHERSCAN_API_KEY=<your_etherscan_api_key>
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/<your_infura_project_id>
```
Please note that infura is now known as "Metamask Developer".

### 💡 Deployment command
Run the following command on the project's root:
```bash
 forge script script/PlantRentalContract.s.sol:DeployPlantRental --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
````

## 👨‍💻 Author
Developed by Guillermo Pastor
📫 Contact: gpastor.kuster@gmail.com