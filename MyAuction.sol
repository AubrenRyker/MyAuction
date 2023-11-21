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

    constructor(address _token, uint256 _reservePrice, uint256 _biddingDuration) {
        owner = msg.sender;
        token = IERC20(_token);
        reservePrice = _reservePrice;
        biddingEndTime = block.timestamp + _biddingDuration;
    }

    function placeBid(uint256 _amount) external onlyBeforeBiddingEnd auctionNotEnded {
        require(_amount > highestBid, "Bid amount must be higher than the current highest bid");
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        if (highestBidder != address(0)) {
            // Refund the previous highest bidder
            require(token.transfer(highestBidder, highestBid), "Bid refund failed");
        }

        highestBid = _amount;
        highestBidder = msg.sender;

        emit BidPlaced(msg.sender, _amount);
    }

function endAuction() external onlyOwner onlyAfterBiddingEnd auctionNotEnded {
        auctionEnded = true;

        if (highestBidder != address(0)) {
            // Transfer the winning bid to the owner
            require(token.transfer(owner, highestBid), "Bid transfer failed");

            emit AuctionEnded(highestBidder, highestBid);
        }
    }

function withdraw() external onlyAfterBiddingEnd auctionNotEnded {
        require(msg.sender != highestBidder, "The highest bidder cannot withdraw until the auction ends");

        // Refund the bid amount
        require(token.transfer(msg.sender, highestBid), "Bid refund failed");
    }


    
}
