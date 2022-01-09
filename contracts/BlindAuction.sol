// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./IPRNG.sol";
import "./PRNG.sol";

contract BlindAuction is ERC721Holder, IPRNG {
    PRNG public prng;

    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    address public nftContract;
    uint256 public nftId;
    uint256 public minimumBid;

    address public royaltyReceiver;
    uint256 public royaltyPercent;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint256 public highestBid;

    // Allowed withdrawals of previous bids that were overbid
    mapping(address => uint256) private pendingReturns;

    event BidPlaced(address bidder);
    event AuctionEnded(address winner, uint256 highestBid);

    /// Method called too early
    error TooEarly(uint256 time);
    /// Method called too late
    error TooLate(uint256 time);
    /// Auction already ended
    error AuctionAlreadyEnded();
    /// Bid not high enough to participate in this auction
    error BidTooLow(uint256 minimumBid);

    // Modifiers are a convenient way to validate inputs to
    // functions. `onlyBefore` is applied to `bid` below:
    // The new function body is the modifier's body where
    // `_` is replaced by the old function body.
    modifier onlyBefore(uint256 time) {
        if (block.timestamp >= time) {
            revert TooLate(time);
        }
        _;
    }
    modifier onlyAfter(uint256 time) {
        if (block.timestamp <= time) {
            revert TooEarly(time);
        }
        _;
    }

    constructor(
        uint256 _biddingTime,
        uint256 _revealTime,
        address payable _beneficiaryAddress,
        uint256 _nftId,
        address _nftContract,
        uint256 _minimumBid,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        address _masterchef
    ) {
        prng = PRNG(computePRNGAddress(_masterchef));
        prng.rotate();

        beneficiary = _beneficiaryAddress;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
        nftContract = _nftContract;
        nftId = _nftId;
        minimumBid = _minimumBid;
        royaltyReceiver = _royaltyReceiver;
        royaltyPercent = _royaltyPercentage;
    }

    /** 
		Place a blinded bid with 
		`blindedBid` = keccak256(abi.encode(value, fake, secret)).
    	The sent ether is only refunded if the bid is correctly
     	revealed in the revealing phase. 
		The bid is valid if the ether sent together with the bid 
		is at least "value" and "fake" is not true. 
		Setting "fake" to true and sending not the exact amount 
		are ways to hide the real bid but still make the required 
		deposit. 
		The same address can place multiple bids.
	*/
    function bid(bytes32 blindedBid) external payable onlyBefore(biddingEnd) {
        prng.rotate();

        bids[msg.sender].push(
            Bid({blindedBid: blindedBid, deposit: msg.value})
        );

        emit BidPlaced(msg.sender);
    }

    /// Reveal your blinded bids. You will get a refund for all
    /// correctly blinded invalid bids and for all bids except for
    /// the totally highest.
    function reveal(
        uint256[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    ) external onlyAfter(biddingEnd) onlyBefore(revealEnd) {
        prng.rotate();

        uint256 length = bids[msg.sender].length;
        require(values.length == length);
        require(fakes.length == length);
        require(secrets.length == length);

        uint256 refund;
        for (uint256 i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];

            (uint256 value, bool fake, bytes32 secret) = (
                values[i],
                fakes[i],
                secrets[i]
            );

            if (
                bidToCheck.blindedBid !=
                keccak256(abi.encode(value, fake, secret))
            ) {
                // Bid was not actually revealed.
                // Do not refund deposit.
                continue;
            }

            refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value)) {
                    refund -= value;
                }
            }

            // Make it impossible for the sender to re-claim
            // the same deposit.
            bidToCheck.blindedBid = bytes32(0);
        }
        Address.sendValue(payable(msg.sender), refund);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[msg.sender] = 0;

            Address.sendValue(payable(msg.sender), amount);
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() public onlyAfter(revealEnd) {
        if (ended) {
            revert AuctionAlreadyEnded();
        }

        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        Address.sendValue(beneficiary, highestBid);
    }

    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(address bidder, uint256 value)
        internal
        returns (bool success)
    {
		// refuse revealed bids that are lower than the current
		// highest bid or that are lower than the minimum bid
        if (value <= highestBid || value < minimumBid) {
            return false;
        }

        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = value;
        highestBidder = bidder;
        return true;
    }
}
