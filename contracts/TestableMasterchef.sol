// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./TestableStackingPanda.sol";
import "./PRNG.sol";
import "./Marketplace/TestableMarketplace.sol";
import "./Marketplace/Marketplace.sol";
import "./DAO/MelodityGovernance.sol";
import "./DAO/MelodityDAOTimelock.sol";
import "./DAO/MelodityDAO.sol";
import "./Stacking/MelodityStacking.sol";

contract TestableMasterchef is ERC721Holder, ReentrancyGuard {
    TestableStackingPanda public stackingPanda;
    PRNG public prng;
    TestableMarketplace public marketplace;
	MelodityGovernance public melodityGovernanceToken;
	MelodityDAOTimelock public melodityDAOTimelock;
	MelodityDAO public melodityDAO;
	MelodityStacking public melodityStacking;
	StackingReceipt public melodityStackingReceipt;

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

	/**
     * Network: Binance Smart Chain (BSC)     *
     * Melodity Bep20: 0x13E971De9181eeF7A4aEAEAA67552A6a4cc54f43

	 * Network: Binance Smart Chain TESTNET (BSC)     *
     * Melodity Bep20: 0x5EaA8Be0ebe73C0B6AdA8946f136B86b92128c55
     */
    constructor() {
		address melodity = 0x13E971De9181eeF7A4aEAEAA67552A6a4cc54f43;

        _deployPRNG();
        _deployStackingPandas();
        _deployMarketplace();
		_deployMelodityGovernance(melodity);
		_deployMelodityDAOTimelock();
		_deployMelodityDAO();
		_deployMelodityStacking(melodity);
    }

    /**
        Deploy stacking pandas NFT contract, deploying this contract let only the
        Masterchef itself mint new NFTs
     */
    function _deployStackingPandas() private {
        stackingPanda = new TestableStackingPanda(address(prng));
        prng.rotate();
    }

    /**
        Deploy the Pseudo Random Number Generator using the create2 method,
        this gives the possibility for other generated smart contract to compute the
        PRNG address and call it
     */
    function _deployPRNG() private {
        prng = new PRNG();
        prng.rotate();
    }

    /**
        Deploy the Marketplace using the create2 method,
        this gives the possibility for other generated smart contract to compute the
        PRNG address and call it
     */
    function _deployMarketplace() private {
        marketplace = new TestableMarketplace(address(prng));
        prng.rotate();
    }

	function _deployMelodityGovernance(address _meld) private {
		melodityGovernanceToken = new MelodityGovernance(IERC20(_meld));
        prng.rotate();
	}

	function _deployMelodityDAOTimelock() private {
		address[] memory proposers = new address[](0);
		address[] memory executor = new address[](1);
		executor[0] = address(0);
		melodityDAOTimelock = new MelodityDAOTimelock(proposers, executor);
        prng.rotate();
	}

	function _deployMelodityDAO() private {
		melodityDAO = new MelodityDAO(melodityGovernanceToken, melodityDAOTimelock);
        prng.rotate();
	}

	function _deployMelodityStacking(address _meld) private {
		melodityStacking = new MelodityStacking(address(this), _meld, address(melodityDAOTimelock), 10);
        prng.rotate();

		melodityStackingReceipt = melodityStacking.stackingReceipt();
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
            TestableStackingPanda.StackingBonus({
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
