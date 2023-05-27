// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface PeriodicDoubleAuction {
    function deposit(
        address _tokenAddress,
        uint256 amount
    ) external returns (bool);

    function balance(address _tokenAddress) external returns (uint256);

    function placeBid(
        uint256 baseAmount,
        uint256 price
    ) external returns (bool);

    function bids() external returns (uint256);

    function placeAsk(
        uint256 baseAmount,
        uint256 price
    ) external returns (bool);
}
