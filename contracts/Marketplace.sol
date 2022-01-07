// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IPRNG.sol";
import "./PRNG.sol";
import "./Auction.sol";

contract Marketplace is IPRNG {
    PRNG public prng;

    Auction[] public auctions;
    address[] public blindAuctions;
    address[] public sales;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    event AuctionCreated(address auction, uint256 nftId, address nftContract);

    /// Trasfer not allowed for Marketplace operator
    error MarketplaceOperatorNotAllowed();
    /// The provided address does not seem to implement the ERC721 NFT standard
    error IncompatibleContractAddress();

    constructor() {
        prng = PRNG(computePRNGAddress(msg.sender));
    }

    /**
        Create a public auction. The auctioner *must* own the NFT to sell.
        Once the auction ends anyone can trigger the release of the funds raised.
        All the participant can also release their bids.
        This contract is not responsible for handling the real auction but only for its creation.

        NOTE: Before actually starting the creation of the auction the user needs
        to allow the transfer of the nft.
     */
    function createAuction(
        uint256 _nftId,
        address _nftContract,
        address _payee,
        uint256 _auctionDuration,
        uint256 _minimumPrice
    ) public returns (address) {
        // smart contract agnostic auction creator
        if (
            // check the SC supports the ERC721 openzeppelin interface
            ERC165Checker.supportsInterface(
                _nftContract,
                _INTERFACE_ID_ERC721
            ) &&
            // check the SC supports the ERC721-Metadata openzeppelin interface
            ERC165Checker.supportsInterface(
                _nftContract,
                _INTERFACE_ID_ERC721_METADATA
            )
        ) {
            // load the instance of the nft contract into the ERC721 interface in order
            // to expose all its methods
            ERC721 nftContractInstance = ERC721(_nftContract);

            // check that the marketplace is allowed to transfer the provided nft
            // for the user
            if (nftContractInstance.getApproved(_nftId) != address(this)) {
                revert MarketplaceOperatorNotAllowed();
            }

            // create a new auction for the user
            Auction auction = new Auction(
                _auctionDuration,
                payable(_payee),
                _nftId,
                _nftContract,
                _minimumPrice
            );
            auctions.push(auction);
            address _auctionAddress = address(auction);

            // move the stacking panda from the owner to the auction contract
            nftContractInstance.safeTransferFrom(msg.sender, _auctionAddress, _nftId);

            emit AuctionCreated(_auctionAddress, _nftId, _nftContract);
            return _auctionAddress;
        }
        revert IncompatibleContractAddress();
    }

    function createBlindAuction() public {}

    function createSale() public {}
}
