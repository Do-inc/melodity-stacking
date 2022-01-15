// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./StackingPanda.sol";
import "./PRNG.sol";
import "./Marketplace.sol";
import "hardhat/console.sol";

contract Masterchef is ERC721Holder, ReentrancyGuard {
    StackingPanda public stackingPanda;
    PRNG public prng;
    Marketplace public marketplace;

    uint256 public mintingEpoch = 7 days;
    uint256 public lastMintingEvent;

    address public DoIncMultisigWallet =
        0x01Af10f1343C05855955418bb99302A6CF71aCB8;

    struct PandaIdentification {
        string name;
        string url;
    }

    PandaIdentification[] public pandas;

    event StackingPandaMinted(uint256 id);
    event StackingPandaForSale(address auction, uint256 id);

    constructor() {
        _deployPRNG();
        _deployStackingPandas();
        _deployMarketplace();
    }

    /**
        Deploy stacking pandas NFT contract, deploying this contract let only the
        Masterchef itself mint new NFTs
     */
    function _deployStackingPandas() private {
        stackingPanda = StackingPanda(
            Create2.deploy(
                0,
                keccak256("Masterchef/StackingPanda"),
                type(StackingPanda).creationCode
            )
        );
        prng.rotate();
    }

    /**
        Deploy the Pseudo Random Number Generator using the create2 method,
        this gives the possibility for other generated smart contract to compute the
        PRNG address and call it
     */
    function _deployPRNG() private {
        prng = PRNG(
            Create2.deploy(
                0,
                keccak256("Masterchef/PRNG"),
                type(PRNG).creationCode
            )
        );
        prng.rotate();
    }

    /**
        Deploy the Marketplace using the create2 method,
        this gives the possibility for other generated smart contract to compute the
        PRNG address and call it
     */
    function _deployMarketplace() private {
        marketplace = Marketplace(
            Create2.deploy(
                0,
                keccak256("Masterchef/Marketplace"),
                type(Marketplace).creationCode
            )
        );
        prng.rotate();
    }

    /**
        Trigger the minting of a new stacking panda, this function is publicly callable
        as the minted NFT will be given to the Masterchef contract.
     */
    function mintStackingPanda() public nonReentrant returns (address) {
        prng.rotate();

        // check that a new panda can be minted
        require(
            block.timestamp >= lastMintingEvent + mintingEpoch,
            "New pandas can be minted only once every 7 days"
        );

        // immediately update the last minting event in order to avoid reetracy
        lastMintingEvent = block.timestamp;

        // retrieve the random number and set the bonus percentage using 18 decimals.
        // NOTE: the maximum percentage here is 7.499999999999999999%
        uint256 meld2meldBonus = prng.rotate() % 7.5 ether;

        // retrieve the random number and set the bonus percentage using 18 decimals.
        // NOTE: the maximum percentage here is 3.999999999999999999%
        uint256 toMeldBonus = prng.rotate() % 4 ether;

        // mint the panda using its name-url from the stored pair and randomly compute the bonuses
        uint256 pandaId = stackingPanda.mint(
            "test",
            "url",
            StackingPanda.StackingBonus({
                decimals: 18,
                meldToMeld: meld2meldBonus,
                toMeld: toMeldBonus
            })
        );

        emit StackingPandaMinted(pandaId);

        return _listForSale(pandaId);
    }

    function _listForSale(uint256 _pandaId) private returns (address) {
        // approve the marketplace to create and start the auction
        stackingPanda.approve(address(marketplace), _pandaId);

        address auction = marketplace.createAuctionWithRoyalties(
            _pandaId,
            address(stackingPanda),
            // Melodity's multisig wallet address
            DoIncMultisigWallet,
            7 days,
            0.1 ether,
            1 ether,
            DoIncMultisigWallet,
            DoIncMultisigWallet
        );

        emit StackingPandaForSale(auction, _pandaId);
        return auction;
    }
}
