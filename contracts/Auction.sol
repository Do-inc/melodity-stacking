// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Auction is ERC721Holder {
    address payable public beneficiary;
    uint256 public auctionEndTime;

    // Current state of the auction.
    address public highestBidder;
    uint256 public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint256) public pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool public ended;

    address public nftContract;
    uint256 public nftId;
    uint256 public minimumBid;

    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event AuctionNotFullfilled(uint256 nftId, address nftContract, uint256 minimumBid);

    /// Auction already ended.
    error AuctionAlreadyEnded();
    /// Higher or equal bid already present.
    error BidNotHighEnough(uint256 highestBid);
    /// Auction not ended yet.
    error AuctionNotYetEnded();
    /// Auction end already called.
    error AuctionEndAlreadyCalled();
    /// Bid not high enough to participate in this auction
    error BidTooLow(uint256 minimumBid);

    /// Create a simple auction with `biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `beneficiaryAddress`.
    constructor(
        uint256 _biddingTime,
        address payable _beneficiaryAddress,
        uint256 _nftId,
        address _nftContract,
        uint256 _minimumBid
    ) {
        beneficiary = _beneficiaryAddress;
        auctionEndTime = block.timestamp + _biddingTime;
        nftContract = _nftContract;
        nftId = _nftId;
        minimumBid = _minimumBid;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() external payable {
        // check that the auction is still in its bidding period
        if (block.timestamp > auctionEndTime) {
            revert AuctionAlreadyEnded();
        }
        
        // check that the bid is higher or equal to the minimum bid to participate
        // in this auction
        if (msg.value < minimumBid) {
            revert BidTooLow(minimumBid);
        }

        // check that the current bid is higher than the previous
        if (msg.value <= highestBid) {
            revert BidNotHighEnough(highestBid);
        }

        if (highestBid != 0) {
            // save the previously highest bid in the pending return pot
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            // send the preivous bid back to the sender
            Address.sendValue(payable(msg.sender), amount);
        }
    }

    /** 
        End the auction and send the highest bid to the beneficiary.
    */
    function endAuction() public {
        // check that the auction is ended
        if (block.timestamp < auctionEndTime) {
            revert AuctionNotYetEnded();
        }
        // check that the auction end call have not already been called
        if (ended) {
            revert AuctionEndAlreadyCalled();
        }

        // mark the auction as ended
        ended = true;

        if (highestBid == 0) {
            // send the NFT to the beneficiary if no bid has been accepted
            ERC721(nftContract).transferFrom(address(this), beneficiary, nftId);
            emit AuctionNotFullfilled(nftId, nftContract, minimumBid);
        }
        else {
            // send the NFT to the bidder
            ERC721(nftContract).transferFrom(address(this), highestBidder, nftId);

            // send the highest bid to the beneficiary
            Address.sendValue(beneficiary, highestBid);

            emit AuctionEnded(highestBidder, highestBid);
        }
    }
}
