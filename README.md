# solidity-double-auction

## MVP Requirements

- a periodic open outcry double auction for ERC20 assets, two assets referred to as `base` and `quote`, bids and offers are specified in the `quote` asset;
- bids and offers can be submitted but not withdrawn;
- clearing occurs every `N` blocks;
