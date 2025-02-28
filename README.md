# StarMint
A Clarity smart contract for minting NFTs to commemorate milestones and achievements.

## Features
- Mint NFTs with milestone metadata (title, description, date, type)
- Transfer NFTs between users
- View milestone details and ownership history
- Set milestone types and access controls

## Setup and Installation
1. Clone the repository
2. Install Clarinet
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to execute test suite

## Usage Examples
```clarity
;; Mint a milestone NFT
(contract-call? .star-mint mint-milestone
  "First Marathon"
  "Completed my first full marathon in 4:23:16"
  "2023-10-15"
  "athletic"
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Transfer milestone NFT
(contract-call? .star-mint transfer-milestone
  u1
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Get milestone details
(contract-call? .star-mint get-milestone-details u1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
