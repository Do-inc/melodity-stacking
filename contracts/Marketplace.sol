// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./IStackingPanda.sol";
import "./IPRNG.sol";
import "./PRNG.sol";
import "./StackingPanda.sol";

contract Marketplace is IPRNG, IStackingPanda {
    PRNG public prng;
    StackingPanda public stackingPanda;
    uint256 private _auctionId;
    uint256 private _blindAuctionId;
    uint256 private _saleId;

    constructor() {
        prng = PRNG(computePRNGAddress(msg.sender));
        stackingPanda = StackingPanda(computeStackingPandaAddress(msg.sender));
    }

    /**
        Create a public auction. The auctioner *must* own the NFT to sell.
        Once the auction ends the creator or the or the payee of the auction can trigger
        the release of the funds raised.
        All the participant can also release their bids.
        This contract is not responsible for handling the real auction but only for its creation.

        NOTE: Before actually starting the creation of the auction the user needs
        to allow the transfer of the nft.
     */
    function createAuction(uint256 _nft_id, address _nft_contract, uint256 _auction_creator) public {
        if(_nft_contract == address(stackingPanda)) {
            require(stackingPanda.getApproved(_nft_id) == address(this), "Trasfer not allowed for Marketplace operator");

            // todo: compute and deploy auction address

            stackingPanda.safeTransferFrom(msg.sender, auction, _nft_id);
        }
        else {

        }
    }

    function createBlindAuction() public {

    }

    function createSale() public {

    }
}