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
*/

contract PeriodicDoubleAuctionImpl is PeriodicDoubleAuction {  

     address public baseAsset;
     address public quoteAsset;
     
     mapping(address => mapping(address => uint256)) private _balances;
     
     string public name;
     
     constructor(string memory _name, 
                 address _baseAsset, 
                 address _quoteAsset) {
          name = _name;
          baseAsset = _baseAsset;
          quoteAsset = _quoteAsset;
     }

     function deposit(address _tokenAddress, uint256 amount) external returns(bool) {
          // check for valid asset
          require(_tokenAddress == baseAsset || _tokenAddress == quoteAsset, "err");
          
          IERC20 erc20 = IERC20(_tokenAddress);

          // check for sufficient allowance
          uint256 allowance = erc20.allowance(msg.sender, address(this));
          require(allowance >= amount, "error");

          bool transferSuccess = erc20.transferFrom(msg.sender, address(this), amount);

          // TODO possibly add a requires here

          _balances[msg.sender][_tokenAddress] += amount;
          return transferSuccess;
     }

}
