// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface PeriodicDoubleAuction {
    function deposit(
        address _tokenAddress,
        uint256 amount
    ) external returns (bool);

    function balance(address _tokenAddress) external returns (uint256);

    function placeBid(uint256 amount, uint256 price) external returns (bool);

    function numberOfBids() external view returns (uint256);

    function placeOffer(uint256 amount, uint256 price) external returns (bool);

    function numberOfOffers() external view returns (uint256);

    function auctionClose() external;
}
