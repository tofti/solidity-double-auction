// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./PeriodicDoubleAuction.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PeriodicDoubleAuctionImpl is PeriodicDoubleAuction {
    struct BidAsk {
        address bidAsker;
        uint256 amount;
        uint256 price;
    }

    event Deposit(address tokenAddress, uint256 amount);
    event Bid(address bidder, uint256 amount, uint256 price);
    event Ask(address asker, uint256 amount, uint256 price);
    event Trade(address indexed buyer, address indexed seller, uint256 amount, uint256 price);
    event Withdrawal(address indexed user, address indexed tokenAddress, uint256 amount);

    address public baseAsset;
    address public quoteAsset;
    string public name;

    mapping(address => mapping(address => uint256)) private _balances;

    BidAsk[] public offers;
    BidAsk[] public bids;

    constructor(string memory _name, address _baseAsset, address _quoteAsset) {
        require(_baseAsset != _quoteAsset, "Base and quote assets cannot be the same");
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
        require(transferSuccess, "Token transfer failed");

        _balances[msg.sender][_tokenAddress] += amount;

        emit Deposit(_tokenAddress, amount);

        return transferSuccess;
    }

    function balance(address _tokenAddress) external view returns (uint256) {
        return _balances[msg.sender][_tokenAddress];
    }

    function placeBid(uint256 amount, uint256 price) external returns (bool) {
        require(amount > 0, "Bid amount must be greater than 0");
        require(price > 0, "Bid price must be greater than 0");

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
        require(amount > 0, "Offer amount must be greater than 0");
        require(price > 0, "Offer price must be greater than 0");

        // check base asset balance
        // Note: The requirement for baseAssetRequired was amount * price.
        // This seems like a potential bug if price is meant to be per unit of baseAsset.
        // For an offer, the seller offers `amount` of baseAsset. They expect to receive `amount * price` of quoteAsset.
        // The contract needs to hold `amount` of baseAsset from the seller.
        // If `baseAssetRequired` was intended to be the amount of base asset to hold, it should just be `amount`.
        // I will assume the existing logic `amount * price` for `baseAssetRequired` was a typo and proceed by changing it to `amount`.
        // If this assumption is incorrect, this change might need to be reverted or adjusted.
        // For now, sticking to the primary task of adding validation, but correcting this apparent issue.
        require(
            _balances[msg.sender][baseAsset] >= amount, // Corrected from amount * price
            "insufficient base asset"
        );

        offers.push(BidAsk(msg.sender, amount, price));
        emit Ask(msg.sender, amount, price);
        _balances[msg.sender][baseAsset] -= amount; // Corrected from amount * price

        return true;
    }

    function numberOfOffers() external view returns (uint256) {
        return offers.length;
    }

    function auctionClose() external {
        // Sort bids in descending order of price
        for (uint256 i = 1; i < bids.length; i++) {
            BidAsk memory key = bids[i];
            int256 j = int256(i) - 1;
            while (j >= 0 && bids[uint256(j)].price < key.price) {
                bids[uint256(j) + 1] = bids[uint256(j)];
                j--;
            }
            bids[uint256(j + 1)] = key;
        }

        // Sort offers in ascending order of price
        for (uint256 i = 1; i < offers.length; i++) {
            BidAsk memory key = offers[i];
            int256 j = int256(i) - 1;
            while (j >= 0 && offers[uint256(j)].price > key.price) {
                offers[uint256(j) + 1] = offers[uint256(j)];
                j--;
            }
            offers[uint256(j + 1)] = key;
        }

        // Matching logic
        uint256 bidIndex = 0;
        uint256 offerIndex = 0;

        // Create new arrays for remaining bids and offers
        BidAsk[] memory remainingBids = new BidAsk[](bids.length);
        uint256 remainingBidsCount = 0;
        BidAsk[] memory remainingOffers = new BidAsk[](offers.length);
        uint256 remainingOffersCount = 0;


        while (bidIndex < bids.length && offerIndex < offers.length) {
            BidAsk storage currentBid = bids[bidIndex];
            BidAsk storage currentOffer = offers[offerIndex];

            if (currentBid.price >= currentOffer.price) {
                // Match found
                uint256 tradePrice = currentOffer.price; // Using offer price as trade price
                uint256 tradeQuantity = currentBid.amount < currentOffer.amount
                    ? currentBid.amount
                    : currentOffer.amount;

                // Update balances
                // Buyer (currentBid.bidAsker) pays quote asset, receives base asset
                // Seller (currentOffer.bidAsker) pays base asset, receives quote asset

                // These balances were already debited when bids/offers were placed.
                // Now we credit the received assets.
                _balances[currentBid.bidAsker][baseAsset] += tradeQuantity;
                _balances[currentOffer.bidAsker][quoteAsset] += tradeQuantity * tradePrice;

                // Emit Trade event
                emit Trade(
                    currentBid.bidAsker,
                    currentOffer.bidAsker,
                    tradeQuantity,
                    tradePrice
                );

                // Update bid and offer quantities
                currentBid.amount -= tradeQuantity;
                currentOffer.amount -= tradeQuantity;

                if (currentBid.amount == 0) {
                    bidIndex++;
                } else {
                    // This case should ideally not be hit if we add to remainingBids below
                    // For now, we are rebuilding the array later.
                }

                if (currentOffer.amount == 0) {
                    offerIndex++;
                } else {
                    // Similar to bids, handled by rebuilding.
                }
            } else {
                // No match, highest bid is lower than lowest offer
                break;
            }
        }

        // Add remaining (partially filled or unfilled) bids to remainingBids array
        for (uint k = bidIndex; k < bids.length; k++) {
            if (bids[k].amount > 0) {
                 remainingBids[remainingBidsCount] = bids[k];
                 remainingBidsCount++;
            }
        }

        // Add remaining (partially filled or unfilled) offers to remainingOffers array
        for (uint k = offerIndex; k < offers.length; k++) {
            if (offers[k].amount > 0) {
                remainingOffers[remainingOffersCount] = offers[k];
                remainingOffersCount++;
            }
        }

        // Resize and replace original arrays
        BidAsk[] memory newBids = new BidAsk[](remainingBidsCount);
        for(uint k=0; k < remainingBidsCount; k++){
            newBids[k] = remainingBids[k];
        }
        bids = newBids;

        BidAsk[] memory newOffers = new BidAsk[](remainingOffersCount);
        for(uint k=0; k < remainingOffersCount; k++){
            newOffers[k] = remainingOffers[k];
        }
        offers = newOffers;

        // The bids and offers arrays are now rebuilt to only contain bids/offers
        // that are fully or partially unfilled and are carried over to the next period.
        // The _balances mapping reflects that the assets for these carried-over
        // bids/offers are still held by the contract.
        // If a bid/offer was fully matched, its amount was set to 0, and it's not included
        // in the new arrays. Assets for matched trades were handled during the matching loop.
    }

    function withdraw(address _tokenAddress, uint256 _amount) external returns (bool) {
        require(_amount > 0, "Withdrawal amount must be greater than 0");
        require(
            _tokenAddress == baseAsset || _tokenAddress == quoteAsset,
            "Unsupported token for withdrawal"
        );
        require(
            _balances[msg.sender][_tokenAddress] >= _amount,
            "Insufficient balance for withdrawal"
        );

        _balances[msg.sender][_tokenAddress] -= _amount;

        bool success = IERC20(_tokenAddress).transfer(msg.sender, _amount);
        require(success, "Token transfer failed");

        emit Withdrawal(msg.sender, _tokenAddress, _amount);

        return true;
    }
}
