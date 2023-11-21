// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Auction {
    address public owner;
    IERC20 public token;
    uint256 public reservePrice;
    uint256 public biddingEndTime;
    uint256 public highestBid;
    address public highestBidder;
    bool public auctionEnded;

    event BidPlaced(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyBeforeBiddingEnd() {
        require(block.timestamp < biddingEndTime, "Bidding has ended");
        _;
    }

    modifier onlyAfterBiddingEnd() {
        require(block.timestamp >= biddingEndTime, "Bidding has not ended");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }

    
}
