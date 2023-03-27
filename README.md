# solidity-double-auction

## MVP Requirements

- a periodic open outcry double auction for ERC20 assets, two assets referred to as `base` and `quote`, bids and offers are specified in the `quote` asset;
- bids and offers can be submitted but not withdrawn;
- clearing occurs every `N` blocks;

## Steps

1. install yarn;
2. install hardhat; `yarn add --dev hardhat`
3. create hardhat project; `yarn hardhat`
4. `yarn add --dev @openzeppelin/contracts`

## TODO

- make ownable;
- make upgradeable;

## Auction Attributes

- base asset;
- quote asset;
- bids / offers (price, size);
- auction ending time;