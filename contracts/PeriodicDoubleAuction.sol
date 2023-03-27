// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

interface PeriodicDoubleAuction {
    function deposit(address _tokenAddress, uint256 amount) external returns(bool);    
    
}
