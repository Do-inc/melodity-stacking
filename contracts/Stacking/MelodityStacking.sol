// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IPRNG.sol";
import "../PRNG.sol";
import "./StackingReceipt.sol";

contract MelodityStacking is IPRNG, Ownable, ReentrancyGuard {
	bytes4 constant public _INTERFACE_ID_ERC20_METADATA = 0x942e8b22;
	address constant public _DO_INC_MULTISIG_WALLET = 0x01Af10f1343C05855955418bb99302A6CF71aCB8;
	uint256 constant public _PERCENTAGE_SCALE = 10 ** 20;
	uint256 constant public _EPOCH_DURATION = 1 hours;
	uint256 constant public _MAX_INT = 2 ** 256 -1;

	

	struct EraInfo {
		uint256 startingTime;
		uint256 endingTime;
		uint256 rewardPerEpoch;
		uint256 eraDuration;
	}

	/**
		+-------------------+ 
	 	|  Stacking values  |
	 	+-------------------+
		@notice funds must be sent to this address in order to actually start rewarding
				users

	 	@dev rewardPool: amount of MELD yet to distribute from this stacking contract
		@dev rewardPerEpoch: reward amount awarded to stackers per epoch
		@dev eraDuration: first era duration misured in seconds
		@dev stackers: address to last deposit time mapping of all the stackers
		@dev currentShares: total stackers share, 1 MELD = 1 share
		@dev genesisTime: time at which the contract was generated
		@dev genesisTime: contract genesis timestamp, used to start eras calculation
		@dev eraInfos: array of EraInfo where startingTime, endingTime, rewardPerEpoch
				and eraDuration gets defined in a per era basis
	*/
    uint256 public rewardPool = 20_000_000 ether;
	uint256 public rewardPerEpoch = 500 ether;
	uint256 public eraDuration = 2500 * _EPOCH_DURATION;
	mapping(address => uint256) public stackers;
	uint256 public currentShares;
	uint256 public genesisTime;
	EraInfo[] public eraInfos;

	/**
		+-----------------------------------+ 
	 	|  Eras and rewards scaling factors  |
	 	+-----------------------------------+
	 	@dev rewardScaleFactor [percentage]: factor that the current reward will be
		 		multiplied to at the end of the current era
		@dev eraScaleFactor [percentage]: factor that the current era duration will be
				multiplied to at the end of the current era
		@dev currentShares: currently applied fee percentage for early withdraw
	*/
	uint256 public rewardScaleFactor = 90 ether;
	uint256 public eraScaleFactor = 110 ether;

	/**
		+--------------+ 
	 	|  Fee values  |
	 	+--------------+
	 	@dev maxFeePercentage: max fee if withdraw occurr before withdrawFeePeriod days
		@dev minFeePercentage: min fee if withdraw occurr before withdrawFeePeriod days
		@dev feePercentage: currently applied fee percentage for early withdraw
		@dev feeReceiver: address where the fees gets sent
		@dev withdrawFeePeriod: number of days or hours that a deposit is considered to 
				under the withdraw with fee period
	*/
	uint256 public maxFeePercentage = 10 ether;
	uint256 public minFeePercentage = 0.1 ether;
	uint256 public feePercentage = maxFeePercentage;
	address public feeReceiver;
	uint256 public withdrawFeePeriod = 7 days;

	/**
		+---------------------------+ 
	 	|  Fee distribution values  |
	 	+---------------------------+
	 	@dev feeReceiverPercentage: share of the fee that goes to the feeReceiver
		@dev feeMaintainerPercentage: share of the fee that goes to the _DO_INC_MULTISIG_WALLET
		@dev feeReceiverMinPercent: minimum percentage that can be given to the feeReceiver
		@dev feeMaintainerMinPercent: minimum percentage that can be given to the _DO_INC_MULTISIG_WALLET
	*/
	uint256 public feeReceiverPercentage = 50 ether;
	uint256 public feeMaintainerPercentage = 50 ether;
	uint256 public feeReceiverMinPercent = 5 ether;
	uint256 public feeMaintainerMinPercent = 25 ether;

    ERC20 public melodity;
	StackingReceipt public stackingReceipt;
    PRNG public prng;

	event Deposit(address depositer, uint256 shares, uint256 depositTime);

	/**
		Initialize the values of the stacking contract

		@param _masterchef The masterchef generator contract address,
			it deploies other contracts
		@param _melodity Melodity ERC20 contract address
	 */
    constructor(address _masterchef, address _melodity, address _dao, uint8 _eras_to_generate) {
		prng = PRNG(computePRNGAddress(_masterchef));
		melodity = ERC20(_melodity);
		stackingReceipt = new StackingReceipt("Melodity stacking receipt", "M2MR");
		
		feeReceiver = _dao;
		genesisTime = block.timestamp;
		_triggerErasInfoRefresh(_eras_to_generate);
    }

	/**
		Trigger the regeneration of _eras_to_generate (at most 128) eras from the current
		one.
		The regenerated eras will use the latest defined eraScaleFactor and rewardScaleFactor
		to compute the eras duration and reward.
		Playing around with the number of eras and the scaling factor caller of this method can
		(re-)generate an arbitrary number of eras (not already started) increasing or decreasing 
		their rewardPerEpoch and eraDuration

		@notice This method overwrites the next era definition first, then moves adding new eras
		@param _eras_to_generate Number of eras to (re-)generate
	 */
	function _triggerErasInfoRefresh(uint8 _eras_to_generate) private {
		uint256 existing_eras_infos = eraInfos.length;
		uint8 i;
		uint8 k;

		while(i < _eras_to_generate) {
			// check if exists some era infos, if they exists check if the k-th era is already started
			// if it is already started it cannot be edited and we won't consider it actually increasing 
			// k
			if(existing_eras_infos > k && eraInfos[k].startingTime <= block.timestamp) {
				k++;
			}
			// if the era is not yet started we can modify its values
			else if(existing_eras_infos > k && eraInfos[k].startingTime > block.timestamp) {
				// get the genesis value or the last one available.
				// NOTE: as this is a modification of existing values the last available value before
				// 		the curren one is stored as the (k-1)-th element of the eraInfos array
				uint256 lastTimestamp = k == 0 ? genesisTime : eraInfos[k - 1].endingTime;
				uint256 lastEraDuration = k == 0 ? eraDuration : eraInfos[k - 1].eraDuration;
				uint256 lastRewardPerEpoch = k == 0 ? rewardPerEpoch : eraInfos[k - 1].rewardPerEpoch;

				uint256 newEraDuration = lastEraDuration * eraScaleFactor / _PERCENTAGE_SCALE;
				eraInfos[k] = EraInfo({
					// new eras starts always the second after the ending of the previous
					// if era-1 ends at sec 1234 era-2 will start at sec 1235
					startingTime: lastTimestamp + 1,
					// dynamically compute the ending time based on the new era duration and the latest
					// eraScaleFactor
					endingTime: lastTimestamp + 1 + newEraDuration,
					rewardPerEpoch: lastRewardPerEpoch * rewardScaleFactor / _PERCENTAGE_SCALE,
					eraDuration: newEraDuration
				});

				// as an era was just updated increase the i counter
				i++;
				// in order to move to the next era or start creating a new one we also need to increase
				// k counter
				k++;
			}
			// start generating new eras info if the number of existing eras is equal to the last computed
			else if(existing_eras_infos == k) {
				// get the genesis value or the last one available
				uint256 lastTimestamp = k == 0 ? genesisTime : eraInfos[k].endingTime;
				uint256 lastEraDuration = k == 0 ? eraDuration : eraInfos[k].eraDuration;
				uint256 lastRewardPerEpoch = k == 0 ? rewardPerEpoch : eraInfos[k].rewardPerEpoch;

				uint256 newEraDuration = lastEraDuration * eraScaleFactor / _PERCENTAGE_SCALE;
				eraInfos.push(EraInfo({
					// new eras starts always the second after the ending of the previous
					// if era-1 ends at sec 1234 era-2 will start at sec 1235
					startingTime: lastTimestamp + 1,
					// dynamically compute the ending time based on the new era duration and the latest
					// eraScaleFactor
					endingTime: lastTimestamp + 1 + newEraDuration,
					rewardPerEpoch: lastRewardPerEpoch * rewardScaleFactor / _PERCENTAGE_SCALE,
					eraDuration: newEraDuration
				}));

				// as an era was just created increase the i counter
				i++;
				// in order to move to the next era and start creating a new one we also need to increase
				// k counter and the existing_eras_infos counter
				existing_eras_infos = eraInfos.length;
				k++;
			}
		}
	}

	/**
		Deposit the provided MELD into the stacking pool

		@param _amount Amount of MELD that will be stacked
	 */
	function deposit(uint256 _amount) public nonReentrant {
		require(_amount > 0, "Unable to deposit null amount");
		require(melodity.balanceOf(msg.sender) >= _amount, "Not enough balance to stake");
		require(melodity.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

		// ALERT: withdraw already earned MELD otherwise the counter will reset

		// transfer the funds from the sender to the stacking contract, the contract balance will
		// increase but the reward pool will not
		melodity.transferFrom(msg.sender, address(this), _amount);

		// update the stackers info with the timestamp of the last deposit
		stackers[msg.sender] = block.timestamp;

		// mint the stacking receipt to the depositor
		stackingReceipt.mint(msg.sender, _amount);

		// update the stacked balance with the new added amount
		currentShares += _amount;

		emit Deposit(msg.sender, _amount, block.timestamp);
	}

	/**

	 */
	function withdraw(uint256 _amount) public nonReentrant {
        require(_amount > 0, "Nothing to withdraw");
		require(
			stackingReceipt.balanceOf(msg.sender) >= _amount, 
			"Not enought receipt to widthdraw"
		);
		require(
			stackingReceipt.allowance(msg.sender, address(this)) >= _amount, 
			"Stacking pool not allowed to withdraw enough of you receipt"
		);

		uint256 currentEraIndex = _getCurrentEra();
		require(currentEraIndex < _MAX_INT, "Internal error, invalid era index");

		// burn the receipt from the sender address
        stackingReceipt.burnFrom(msg.sender, _amount);

		uint256 lastDepositTime = stackers[msg.sender];
		EraInfo memory currentEra = eraInfos[currentEraIndex];

		// check if the last deposit was done prior to the current era
        if(lastDepositTime < currentEra.startingTime) {
			// TODO: handle the calculation of the revenue for epoch prior to the current era
		}


    }

	/**
		Get the number of epoch an account stacked its funds in the provided era.

		@param _account Stacker account to check epoch count for
		@param _eraIndex Index of the era to check for
		@return _stackedEpochs Number of epoch the account stacked its funds in the current era
		@return _stackedInPreviousEra Whether the account stacked its funds in the previous era or not
	 */
	function _getStackedEpochsInEra(address _account, uint256 _eraIndex) private view 
		returns(uint256 _stackedEpochs, bool _stackedInPreviousEra) 
	{
		uint256 lastAction = stackers[_account];
		EraInfo memory info = eraInfos[_eraIndex];

		// check that the last action was done prior to the given era, if it is not, no epoch was passed in the
		// given era
		if(lastAction > info.endingTime) {
			return (0, false);
		}
		// check if the last action was done in a previous era
		else if(lastAction < info.startingTime) {
			uint256 _now = info.endingTime;

			// check if the current era is already ended, if it is not use the current timestamp for
			// epoch calculation
			if(info.endingTime > block.timestamp) {
				_now = block.timestamp;
			}

			// check if last action was done at least an epoch before the beginning of the provided
			// era, if it is then assume the last action for the provided era was the era starting time
			// NOTE: using the era starting time as the last action may result in the loss of an epoch
			//		reward if is not fully completed before the era ending time
			if(lastAction - info.startingTime >= _EPOCH_DURATION) {
				lastAction = info.startingTime;
			}

			return ((_now - lastAction) / _EPOCH_DURATION, true);
		}
		// last action was done in the provided era
		else {
			uint256 _now = info.endingTime;

			// check if the current era is already ended, if it is not use the current timestamp for
			// epoch calculation
			if(info.endingTime > block.timestamp) {
				_now = block.timestamp;
			}

			return ((_now - lastAction) / _EPOCH_DURATION, false);
		}
	}

	/**
		Computes the total reward per a given era that an account should receive

		@param _account Account to retrieve the reward for
		@param _eraIndex Index of the era to compute for
		@return _reward Reward amount that should be given to the user for the provided era
		@return _hasPreviousEra Whether the account stacked its funds in the previous era or not
	 */
	function _getRewardPerEra(address _account, uint256 _eraIndex, uint256 _shares) private view returns(uint256 _reward, bool _hasPreviousEra) {
		(uint256 stackedEpochs, bool hasPreviousEra) = _getStackedEpochsInEra(_account, _eraIndex);

		EraInfo memory info = eraInfos[_eraIndex];

		return (stackedEpochs * info.rewardPerEpoch, hasPreviousEra);
	}

	function getTotalReward(address _account) public view returns(uint256) {
		// TODO: return the total reward to give to an account, this value must be era indipendent
		return 0;
	}

	/**
		Internal version of getCurrentEra, the two methods works exactly the same except that the public
		method returns the ordered numeric representation while the private returns the index.

		@return current era index or _MAX_INT if no era fits the current timestamp
	 */
	function _getCurrentEra() private view returns(uint256) {
		for (uint256 i; i < eraInfos.length; i++) {
			if(block.timestamp >= eraInfos[i].startingTime && block.timestamp <= eraInfos[i].endingTime) {
				return i;
			}
		}
		return _MAX_INT;
	}

	/**
		Public version of _getCurrentEra, the two methods works exactly the same except that the public
		method returns the ordered numeric representation while the private returns the index.

		@return current era ordered number or _MAX_INT if no era fits the current timestamp
	 */
	function getCurrentEra() public view returns(uint256) {
		for (uint256 i; i < eraInfos.length; i++) {
			if(block.timestamp >= eraInfos[i].startingTime && block.timestamp <= eraInfos[i].endingTime) {
				return i + 1;
			}
		}
		return _MAX_INT;
	}
}
