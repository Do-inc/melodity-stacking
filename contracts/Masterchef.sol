//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./StackingPanda.sol";

contract Masterchef {
    StackingPanda public stackingPanda;

    constructor() {
        _deployStackingPandas();
    }

    /**
        Deploy stacking pandas NFT contract, deploying this contract let only the
        Masterchef itself mint new NFTs
     */
    function _deployStackingPandas() private {
        bytes32 salt = keccak256("Melodity Stacking Pandas");
        stackingPanda = StackingPanda(
            Create2.deploy(0, salt, type(StackingPanda).creationCode)
        );
    }

    function triggerMinting() public {
        stackingPanda.mint("test", "url", StackingPanda.StackingBonus({
            decimals: 18,
            meldToMeld: 1.5 ether,
            toMeld: .5 ether
        }));
    }
}