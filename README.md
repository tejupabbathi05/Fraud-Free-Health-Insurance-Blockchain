# Fraud-Free Health Insurance Claim Verification using Blockchain

This project implements a fraud-free health insurance claim verification system using blockchain technology.

Users can submit insurance claims and upload medical reports. The insurance company maintains a list of registered hospitals. Hospitals upload the hash of verified medical reports to the blockchain.

When a claim is submitted, the system generates the hash of the user-uploaded report and compares it with the hash stored on the blockchain by the hospital. If both hashes match, the claim is approved; otherwise, the claim is rejected.

By storing report hashes on the blockchain, the system ensures that medical records cannot be altered, helping prevent fraudulent insurance claims.

## Technologies Used
- Solidity
- Truffle
- JavaScript
- HTML
- Blockchain (Ethereum)
- 
## Requirements
To run this project, make sure the following tools are installed:
- Node.js
- Truffle Framework
- MetaMask browser extension
- Ethereum test network (Ganache / Truffle develop)
