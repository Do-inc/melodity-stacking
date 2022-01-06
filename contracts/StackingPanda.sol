//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IPRNG.sol";

contract StackingPanda is ERC721, Ownable, IPRNG {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct StackingBonus {
        uint8 decimals;
        uint256 meldToMeld;
        uint256 toMeld;
    }

    struct Metadata {
        string name;
        string picUrl;
        StackingBonus bonus;
    }

    Metadata[] private metadata;

    address public masterchef;
    PRNG private prng;

    // Init the NFT contract with the ownable abstact in order to let only the owner
    // mint new NFTs
    constructor() ERC721("Melodity Stacking Panda", "STACKP") Ownable() {
        masterchef = msg.sender;
        prng = PRNG(computePRNGAddress(masterchef));
    }

    /**
        Mint new NFTs, the maximum number of mintable NFT is 100.
        Only the owner of the contract can call this method.
        NFTs will be minted to the owner of the contract (alias, the creator); in order
        to let the Masterchef sell the NFT immediately after minting this contract *must*
        be deployed onchain by the Masterchef itself.

        @param _name Panda NFT name
        @param _picUrl The url where the picture is stored
        @param _stackingBonus As these NFTs are designed to give stacking bonuses this 
                value defines the reward bonuses
     */
    function mint(string memory _name, string memory _picUrl, StackingBonus memory _stackingBonus) public onlyOwner returns (uint256)
    {
        prng.rotate();

        // Only 100 NFTs will be mintable
        require(_tokenIds.current() < 100, "All pandas minted");

        uint256 newItemId = _tokenIds.current();
        _tokenIds.increment();

        metadata.push(Metadata({
            name: _name,
            picUrl: _picUrl,
            bonus: _stackingBonus
        }));
        _mint(owner(), newItemId);

        return newItemId;
    }

    function getMetadata(uint256 _nftId) public view returns (Metadata memory) {
        return metadata[_nftId];
    }
}
