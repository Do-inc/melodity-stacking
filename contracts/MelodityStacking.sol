// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165CheckerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IPRNG.sol";
import "./PRNG.sol";
import "hardhat/console.sol";

contract MelodityStackingV1 is IPRNG, Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    uint256 public rewardPool;
	uint256 public rewardPerEpoch;
	uint256 public epochDuration;
	uint256 public eraDuration;
	uint256 public rewardScaleFactor;
	uint256 public eraScaleFactor;
	uint256 public currentShares;

	uint256 public maxFee;
	uint256 public minFee;
	uint256 public fee;
	address public feeReceiver;
	uint256 public withdrawFeePeriod;

    ERC20 public melodity;
    PRNG public prng;

	struct Info {
		uint256 share;
		uint256 lastDeposited;
	}

	mapping(address => Info) public stackers;

	event Deposit(address depositer, uint256 shares, uint256 depositTime);

	// Unneeded here
    // bytes4 public _INTERFACE_ID_ERC20_METADATA = 0x942e8b22;

	/**
		Contract initialization function, substitutes the contructor for
		upgradable contracts.
		This method can be called only one time and sets all the default
		values.

		@param _masterchef The masterchef generator contract address,
			it deploies other contracts
		@param _melodity Melodity ERC20 contract address
	 */
    function initialize(address _masterchef, address _melodity, address _dao)
        public
		initializer
    {
		prng = PRNG(computePRNGAddress(_masterchef));
		melodity = ERC20(_melodity);

		// set the default reward pool.
		// NOTE: funds must be sent to this address in order to actually start
		// 	rewarding users
		rewardPool = 20_000_000 ether;
		rewardPerEpoch = 500 ether;

		epochDuration = 1 hours;
		eraDuration = 2500 * epochDuration;

		// reward and era scale factor, at the end of each era the
		// rewardPerEpoch will be multiplied for 90% and the era will be
		// multiplied for 110%
		rewardScaleFactor = 90 ether;
		eraScaleFactor = 110 ether;

		// max fee if withdraw occurr before 7 days is 10%
		maxFee = 10 ether;
		// min fee if withdraw occurr before 7 days is 0.1%
		minFee = 0.1 ether;
		fee = maxFee;
		feeReceiver = _dao;
		withdrawFeePeriod = 7 days;
    }

	/**
		Openzeppeling authorization function used for contract upgrading, this can be called
		only by the proxy administrator.
		As upgrading a reward pool means actually exporting the available rewards to a new contract
		this method triggers the approval of the transfer to the new contract.
		NOTE: this method does not locks widthdraws.

		@param newImplementation address of the new implementation contract
	 */
	function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

	/**
		Deposit the provided melodities into the stacking pool

		@param _amount Amount of MELD that will be stacked
	 */
	function deposit(uint256 _amount) public nonReentrant virtual {
		require(_amount > 0, "Unable to deposit empty amount");
		require(melodity.balanceOf(msg.sender) >= _amount, "Not enough balance to stake");
		require(melodity.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

		// transfer the funds from the sender to the stacking contract, the contract balance will
		// increase but the reward pool will not
		melodity.transferFrom(msg.sender, address(this), _amount);

		// update the stackers info with the new amount of funds
		Info storage info = stackers[msg.sender];
		info.lastDeposited = block.timestamp;
		info.share += _amount;

		// update the stacked balance with the new added amount
		currentShares += _amount;

		emit Deposit(msg.sender, _amount, info.lastDeposited);
	}
}
