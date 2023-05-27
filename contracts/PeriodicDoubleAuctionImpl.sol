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
        address bidder;
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
            "err"
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
        // TODO possibly add a requires here

        _balances[msg.sender][_tokenAddress] += amount;

        emit Deposit(_tokenAddress, amount);

        return transferSuccess;
    }

    function balance(address _tokenAddress) external view returns (uint256) {
        return _balances[msg.sender][_tokenAddress];
    }

    function placeBid(
        uint256 baseAmount,
        uint256 price
    ) external returns (bool) {
        // validation

        // check quote asset balance
        uint256 quoteAssetRequired = baseAmount * price;
        require(
            _balances[msg.sender][quoteAsset] >= quoteAssetRequired,
            "insufficient quote asset"
        );

        bids.push(BidAsk(msg.sender, baseAmount, price));
        emit Bid(msg.sender, baseAmount, price);
        return true;
    }

    function bids() external returns (uint256) {
        return bids.length;
    }

    function placeAsk(
        uint256 baseAmount,
        uint256 price
    ) external pure returns (bool) {
        // check base asset balance

        return true;
    }
}
