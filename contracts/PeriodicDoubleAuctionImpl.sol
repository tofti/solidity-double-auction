// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./PeriodicDoubleAuction.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
- base asset;
- quote asset;
- bids / offers (price, size);
- auction ending time;

- questions?
- can you place multiple bids? and offers?
*/

contract PeriodicDoubleAuctionImpl is PeriodicDoubleAuction {
    struct BidAsk {
        address bidAsker;
        uint256 amount;
        uint256 price;
    }

    event Deposit(address tokenAddress, uint256 amount);
    event Bid(address bidder, uint256 amount, uint256 price);
    event Ask(address asker, uint256 amount, uint256 price);

    address public baseAsset;
    address public quoteAsset;
    string public name;

    mapping(address => mapping(address => uint256)) private _balances;

    BidAsk[] public offers;
    BidAsk[] public bids;

    constructor(string memory _name, address _baseAsset, address _quoteAsset) {
        name = _name;
        // TODO validation check these are not the same asset
        baseAsset = _baseAsset;
        quoteAsset = _quoteAsset;
    }

    function deposit(
        address _tokenAddress,
        uint256 amount
    ) external returns (bool) {
        // check for valid asset
        require(
            _tokenAddress == baseAsset || _tokenAddress == quoteAsset,
            "Unsupported token deposited"
        );

        IERC20 erc20 = IERC20(_tokenAddress);

        // check for sufficient allowance
        uint256 allowance = erc20.allowance(msg.sender, address(this));
        require(allowance >= amount, "insufficient allowance");

        bool transferSuccess = erc20.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        // TODO possibly add a requires here on the success value

        _balances[msg.sender][_tokenAddress] += amount;

        emit Deposit(_tokenAddress, amount);

        return transferSuccess;
    }

    function balance(address _tokenAddress) external view returns (uint256) {
        return _balances[msg.sender][_tokenAddress];
    }

    function placeBid(uint256 amount, uint256 price) external returns (bool) {
        // validation

        // check quote asset balance
        uint256 quoteAssetRequired = amount * price;
        require(
            _balances[msg.sender][quoteAsset] >= quoteAssetRequired,
            "insufficient quote asset"
        );

        bids.push(BidAsk(msg.sender, amount, price));
        emit Bid(msg.sender, amount, price);
        _balances[msg.sender][quoteAsset] -= quoteAssetRequired;

        return true;
    }

    function numberOfBids() external view returns (uint256) {
        return bids.length;
    }

    function placeOffer(uint256 amount, uint256 price) external returns (bool) {
        // validation

        // check base asset balance

        uint256 baseAssetRequired = amount * price;
        require(
            _balances[msg.sender][baseAsset] >= baseAssetRequired,
            "insufficient base asset"
        );

        offers.push(BidAsk(msg.sender, amount, price));
        emit Ask(msg.sender, amount, price);
        _balances[msg.sender][baseAsset] -= baseAssetRequired;

        return true;
    }

    function numberOfOffers() external view returns (uint256) {
        return offers.length;
    }
}
