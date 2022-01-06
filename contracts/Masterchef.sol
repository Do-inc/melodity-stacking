//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./StackingPanda.sol";
import "./PRNG.sol";
import "hardhat/console.sol";

contract Masterchef {
    StackingPanda public stackingPanda;
    PRNG public prng;

    uint256 public mintingEpoch = 84 hours;
    uint256 public lastMintingEvent;
    uint256 public lastPandaId;

    struct PandaIdentification {
        string name;
        string url;
    }

    PandaIdentification[] public pandas;

    event StackingPandaMinted(uint256 id);
    event StackingPandaForSale(
        uint256 id,
        uint256 meld2meldBonus,
        uint256 toMeldBonus
    );

    constructor() {
        _deployPRNG();
        _deployStackingPandas();
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
        Trigger the minting of a new stacking panda, this function is publicly callable
        as the minted NFT will be given to the Masterchef contract.
        // TODO: trigger listing once minted
     */
    function mintStackingPanda() public {
        prng.rotate();

        require(
            block.timestamp > lastMintingEvent + mintingEpoch,
            "New pandas can be minted only once every 84h"
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

        lastPandaId = pandaId + 1;

        emit StackingPandaMinted(pandaId);

        _listForSale(pandaId);
    }

    function _listForSale(uint256 _pandaId) private {}
}
