// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../IPRNG.sol";
import "../IStackingPanda.sol";
import "../StackingPanda.sol";
import "../PRNG.sol";
import "./StackingReceipt.sol";

contract MelodityStacking is IPRNG, IStackingPanda, ERC721Holder, Ownable, Pausable, ReentrancyGuard {
	bytes4 constant public _INTERFACE_ID_ERC20_METADATA = 0x942e8b22;
	address constant public _DO_INC_MULTISIG_WALLET = 0x01Af10f1343C05855955418bb99302A6CF71aCB8;
	uint256 constant public _PERCENTAGE_SCALE = 10 ** 20;
	uint256 constant public _EPOCH_DURATION = 1 hours;
	uint256 constant public _MAX_INT = 2 ** 256 -1;

	/**
		@param startingTime Era starting time
		@param eraDuration Era duration (in seconds)
		@param rewardScaleFactor Factor that the current reward will be
		 		multiplied to at the end of the current era
		@param eraScaleFactor Factor that the current era duration will be
				multiplied to at the end of the current era
	 */
	struct EraInfo {
		uint256 startingTime;
		uint256 eraDuration;
		uint256 rewardScaleFactor;
		uint256 eraScaleFactor;
	}

	/**
		@param rewardPool Amount of MELD yet to distribute from this stacking contract
		@param receiptValue Receipt token value
		@param lastReceiptUpdateTime Last update time of the receipt value
		@param eraDuration First era duration misured in seconds
		@param genesisEraDuration Contract genesis timestamp, used to start eras calculation
		@param genesisRewardScaleFactor Contract genesis reward scaling factor
		@param genesisEraScaleFactor Contract genesis era scaling factor
	 */
	struct PoolInfo {
		uint256 rewardPool;
		uint256 receiptValue;
		uint256 lastReceiptUpdateTime;
		uint256 genesisEraDuration;
		uint256 genesisTime;
		uint256 genesisRewardScaleFactor;
		uint256 genesisEraScaleFactor;
		bool exhausting;
	}

	/**
		@param maxFeePercentage Max fee if withdraw occurr before withdrawFeePeriod days
		@param minFeePercentage Min fee if withdraw occurr before withdrawFeePeriod days
		@param feePercentage Currently applied fee percentage for early withdraw
		@param feeReceiver Address where the fees gets sent
		@param withdrawFeePeriod Number of days or hours that a deposit is considered to 
				under the withdraw with fee period
		@param feeReceiverPercentage Share of the fee that goes to the feeReceiver
		@param feeMaintainerPercentage Share of the fee that goes to the _DO_INC_MULTISIG_WALLET
		@param feeReceiverMinPercent Minimum percentage that can be given to the feeReceiver
		@param feeMaintainerMinPercent Minimum percentage that can be given to the _DO_INC_MULTISIG_WALLET
	 */
	struct FeeInfo {
		uint256 maxFeePercentage;
		uint256 minFeePercentage;
		uint256 feePercentage;
		address feeReceiver;
		uint256 withdrawFeePeriod;
		uint256 feeReceiverPercentage;
		uint256 feeMaintainerPercentage;
		uint256 feeReceiverMinPercent;
		uint256 feeMaintainerMinPercent;
	}

	struct StackedNFT {
		uint256 stackedAmount;
		uint256 nftId;
	}

	/**
		+-------------------+ 
	 	|  Stacking values  |
	 	+-------------------+
		@notice funds must be sent to this address in order to actually start rewarding
				users

		@dev poolInfo: pool information container
		@dev eraInfos: array of EraInfo where startingTime, endingTime, rewardPerEpoch
				and eraDuration gets defined in a per era basis
		@dev stackersLastDeposit: stacker last executed deposit, reset at each deposit
	*/
	PoolInfo public poolInfo;
	FeeInfo public feeInfo;
	EraInfo[] public eraInfos;
	mapping(address => uint256) private stackersLastDeposit;
	mapping(address => StackedNFT[]) public stackedNFTs;

    ERC20 public melodity;
	StackingReceipt public stackingReceipt;
    PRNG public prng;
	StackingPanda public stackingPanda;

	event Deposit(address account, uint256 amount, uint256 receiptAmount, uint256 depositTime);
	event NFTDeposit(address account, uint256 nftId);
	event ReceiptValueUpdate(uint256 value);
	event Withdraw(address account, uint256 amount, uint256 receiptAmount);
	event NFTWithdraw(address account, uint256 nftId);
	event FeePaid(uint256 amount, uint256 receiptAmount);
	event RewardPoolIncreased(uint256 insertedAmount);
	event PoolExhausting(uint256 amountLeft);
	event EraDurationUpdate(uint256 oldDuration, uint256 newDuration);
	event RewardScalingFactorUpdate(uint256 oldFactor, uint256 newFactor);
	event EraScalingFactorUpdate(uint256 oldFactor, uint256 newFactor);
	event EarlyWithdrawFeeUpdate(uint256 oldFactor, uint256 newFactor);
	event FeeReceiverUpdate(address _old, address _new);
	event WithdrawPeriodUpdate(uint256 oldPeriod, uint256 newPeriod);
	event DaoFeeSharedUpdate(uint256 oldShare, uint256 newShare);
	event MaintainerFeeSharedUpdate(uint256 oldShare, uint256 newShare);

	/**
		Initialize the values of the stacking contract

		@param _masterchef The masterchef generator contract address,
			it deploies other contracts
		@param _melodity Melodity ERC20 contract address
	 */
    constructor(address _masterchef, address _melodity, address _dao, uint8 _eras_to_generate) {
		prng = PRNG(computePRNGAddress(_masterchef));
		stackingPanda = StackingPanda(computeStackingPandaAddress(_masterchef));
		melodity = ERC20(_melodity);
		stackingReceipt = new StackingReceipt("Melodity stacking receipt", "sMELD");
		
		poolInfo = PoolInfo({
			rewardPool: 20_000_000 ether,
			receiptValue: 1 ether,
			lastReceiptUpdateTime: block.timestamp,
			genesisEraDuration: 720 * _EPOCH_DURATION,
			genesisTime: block.timestamp,
			genesisRewardScaleFactor: 79 ether,
			genesisEraScaleFactor: 107 ether,
			exhausting: false
		});

		feeInfo = FeeInfo({
			maxFeePercentage: 10 ether,
			minFeePercentage: 0.1 ether,
			feePercentage: 10 ether,
			feeReceiver: _dao,
			withdrawFeePeriod: 7 days,
			feeReceiverPercentage: 50 ether,
			feeMaintainerPercentage: 50 ether,
			feeReceiverMinPercent: 5 ether,
			feeMaintainerMinPercent: 25 ether
		});

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
				uint256 lastTimestamp = k == 0 ? poolInfo.genesisTime : eraInfos[k - 1].startingTime + eraInfos[k - 1].eraDuration;
				uint256 lastEraDuration = k == 0 ? poolInfo.genesisEraDuration : eraInfos[k - 1].eraDuration;
				uint256 lastEraScalingFactor = k == 0 ? poolInfo.genesisEraScaleFactor : eraInfos[k - 1].eraScaleFactor;
				uint256 lastRewardScalingFactor = k == 0 ? poolInfo.genesisRewardScaleFactor : eraInfos[k - 1].rewardScaleFactor;

				uint256 newEraDuration = lastEraDuration * lastEraScalingFactor / _PERCENTAGE_SCALE;
				eraInfos[k] = EraInfo({
					// new eras starts always the second after the ending of the previous
					// if era-1 ends at sec 1234 era-2 will start at sec 1235
					startingTime: lastTimestamp + 1,
					eraDuration: newEraDuration,
					rewardScaleFactor: lastRewardScalingFactor,
					eraScaleFactor: lastEraScalingFactor
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
				uint256 lastTimestamp = k == 0 ? poolInfo.genesisTime : eraInfos[k - 1].startingTime + eraInfos[k - 1].eraDuration;
				uint256 lastEraDuration = k == 0 ? poolInfo.genesisEraDuration : eraInfos[k].eraDuration;
				uint256 lastEraScalingFactor = k == 0 ? poolInfo.genesisEraScaleFactor : eraInfos[k - 1].eraScaleFactor;
				uint256 lastRewardScalingFactor = k == 0 ? poolInfo.genesisRewardScaleFactor : eraInfos[k - 1].rewardScaleFactor;

				uint256 newEraDuration = lastEraDuration * lastEraScalingFactor / _PERCENTAGE_SCALE;
				eraInfos.push(EraInfo({
					// new eras starts always the second after the ending of the previous
					// if era-1 ends at sec 1234 era-2 will start at sec 1235
					startingTime: lastTimestamp + 1,
					eraDuration: newEraDuration,
					rewardScaleFactor: lastRewardScalingFactor,
					eraScaleFactor: lastEraScalingFactor
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
	function deposit(uint256 _amount) public nonReentrant returns(uint256) {
		prng.rotate();

		require(_amount > 0, "Unable to deposit null amount");
		require(melodity.balanceOf(msg.sender) >= _amount, "Not enough balance to stake");
		require(melodity.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

		refreshReceiptValue();

		// transfer the funds from the sender to the stacking contract, the contract balance will
		// increase but the reward pool will not
		melodity.transferFrom(msg.sender, address(this), _amount);

		// update the last deposit time, reset the withdraw fee timer
		stackersLastDeposit[msg.sender] = block.timestamp;

		// mint the stacking receipt to the depositor
		uint256 receiptAmount = _amount / poolInfo.receiptValue;
		stackingReceipt.mint(msg.sender, receiptAmount);

		emit Deposit(msg.sender, _amount, receiptAmount, block.timestamp);

		return receiptAmount;
	}

	/**
		Deposit the provided MELD into the stacking pool.
		This method deposits also the provided NFT into the stacking pool and mints the bonus receipts
		to the stacker

		@param _amount Amount of MELD that will be stacked
		@param _nftId NFT identifier that will be stacked with the funds
	 */
	function depositWithNFT(uint256 _amount, uint256 _nftId) public nonReentrant {
		prng.rotate();

		require(stackingPanda.ownerOf(_nftId) == msg.sender, "You're not the owner of the provided NFT");
		require(stackingPanda.getApproved(_nftId) == address(this), "Stacking pool not allowed to withdraw your NFT");

		// withdraw the nft from the sender
		stackingPanda.safeTransferFrom(msg.sender, address(this), _nftId);
		StackingPanda.Metadata memory metadata = stackingPanda.getMetadata(_nftId);

		// make a standard deposit with the funds
		uint256 receipt = deposit(_amount);

		// compute and mint the stacking receipt of the bonus given by the NFT
		uint256 bonusAmount = _amount * metadata.bonus.meldToMeld / _PERCENTAGE_SCALE;
		uint256 receiptAmount = bonusAmount / poolInfo.receiptValue;
		stackingReceipt.mint(msg.sender, receiptAmount);
		
		// In order to withdraw the nft the stacked amount for the given NFT *MUST* be zero
		stackedNFTs[msg.sender].push(StackedNFT({
			stackedAmount: receipt + receiptAmount,
			nftId: _nftId
		}));

		emit NFTDeposit(msg.sender, _nftId);
	}

	/**
		Withdraw the receipt from the pool 

		@param _amount Receipt amount to reconver to MELD
	 */
	function withdraw(uint256 _amount) public nonReentrant {
		prng.rotate();

        require(_amount > 0, "Nothing to withdraw");
		require(
			stackingReceipt.balanceOf(msg.sender) >= _amount, 
			"Not enought receipt to widthdraw"
		);
		require(
			stackingReceipt.allowance(msg.sender, address(this)) >= _amount, 
			"Stacking pool not allowed to withdraw enough of you receipt"
		);

		refreshReceiptValue();

		// burn the receipt from the sender address
        stackingReceipt.burnFrom(msg.sender, _amount);

		uint256 meldToWithdraw = _amount * poolInfo.receiptValue;

		// reduce the reward pool
		poolInfo.rewardPool -= meldToWithdraw;
		_checkIfExhausting();

		uint256 lastAction = stackersLastDeposit[msg.sender];
		uint256 _now = block.timestamp;

		// check if the last deposit was done at least feeInfo.withdrawFeePeriod seconds
		// in the past, if it was then the user has no fee to pay for the withdraw
		// proceed with a direct transfer of the balance needed
		if(lastAction < _now && lastAction + feeInfo.withdrawFeePeriod < _now) {
			melodity.transfer(msg.sender, meldToWithdraw);
			emit Withdraw(msg.sender, meldToWithdraw, _amount);
		}
		// user have to pay withdraw fee
		else {
			uint256 fee = meldToWithdraw * feeInfo.feePercentage / _PERCENTAGE_SCALE;
			// deduct fee from the amount to withdraw
			meldToWithdraw -= fee;

			// split fee with dao and maintainer
			uint256 daoFee = fee * feeInfo.feeReceiverPercentage / _PERCENTAGE_SCALE;
			uint256 maintainerFee = fee - daoFee;

			melodity.transfer(feeInfo.feeReceiver, daoFee);
			melodity.transfer(_DO_INC_MULTISIG_WALLET, maintainerFee);
			emit FeePaid(fee, fee * poolInfo.receiptValue);

			melodity.transfer(msg.sender, meldToWithdraw);
			emit Withdraw(msg.sender, meldToWithdraw, _amount);
		}
    }

	function withdrawWithNFT(uint256 _amount, uint256 _index) public nonReentrant {
		prng.rotate();
		
		require(stackedNFTs[msg.sender].length > _index, "Index out of bound");

		// run the standard withdraw
		withdraw(_amount);

		StackedNFT storage stackedNFT = stackedNFTs[msg.sender][_index];

		// if the amount withdrawn is greater or equal to the stacked amount than allow the
		// withdraw of the NFT
		// ALERT: withdrawing an amount higher then the deposited one and having more than
		//		one NFT stacked may lead to the permanent lock of the NFT in the contract.
		//		The NFT may be retrieved re-providing the funds for stacking and withdrawing
		//		the required amount of funds using this method
		if(_amount >= stackedNFT.stackedAmount) {
			// avoid overflow with 1 nft only, swap the element and the latest one only
			// if the array has more than one element
			if(stackedNFTs[msg.sender].length -1 > 0) {
				stackedNFTs[msg.sender][_index] = stackedNFTs[msg.sender][stackedNFTs[msg.sender].length - 1];
			}
			// remove the element from the array
			stackedNFTs[msg.sender].pop();

			// refund the NFT to the original owner
			stackingPanda.safeTransferFrom(address(this), msg.sender, stackedNFT.nftId);
			emit NFTWithdraw(msg.sender, stackedNFT.nftId);
		}
		// otherwise simply reduce the stacked amount by the withdrawn amount
		else {
			stackedNFT.stackedAmount -= _amount;
		}
	}

	/**
		Checks if the reward pool is less then 1mln MELD, if it is mark the pool
		as exhausting and emit the PoolExhausting event
	 */
	function _checkIfExhausting() private {
		if(poolInfo.rewardPool < 1_000_000 ether) {
			poolInfo.exhausting = true;
			emit PoolExhausting(poolInfo.rewardPool);
		}
	}

	/**
		Update the receipt value if necessary
	 */
	function refreshReceiptValue() public {
		uint256 _now = block.timestamp;
		uint256 lastUpdateTime = poolInfo.lastReceiptUpdateTime;
		require(lastUpdateTime < _now, "Receipt value already update in this transaction");

		poolInfo.lastReceiptUpdateTime = block.timestamp;

		uint256 eraEndingTime;

		for(uint256 i; i < eraInfos.length; i++) {
			eraEndingTime = eraInfos[i].startingTime + eraInfos[i].eraDuration;

			// check if the lastUpdateTime is inside the currently checking era
			if(eraInfos[i].startingTime <= lastUpdateTime && lastUpdateTime <= eraEndingTime) {
				// check if _now is in the same era of the lastUpdateTime, if it is then use _now to recompute the receipt value
				if(eraInfos[i].startingTime <= _now && _now <= eraEndingTime) {
					// NOTE: here some epochs may get lost as lastUpdateTime will almost never be equal to the exact epoch
					// 		update time, in order to avoid this error we compute the difference from the lastUpdateTime
					//		and the difference from the start of this era, as the two value will differ most of the times
					//		we compute the real number of epoch from the last fully completed one
					uint256 diffSinceLastUpdate = _now - lastUpdateTime;
					uint256 epochsSinceLastUpdate = diffSinceLastUpdate / _EPOCH_DURATION;

					uint256 diffSinceEraStart = _now - eraInfos[i].startingTime;
					uint256 epochsSinceEraStart = diffSinceEraStart / _EPOCH_DURATION;

					uint256 missingFullEpochs;

					if(epochsSinceEraStart > epochsSinceLastUpdate) {
						missingFullEpochs = epochsSinceEraStart - epochsSinceLastUpdate;
					}

					// recompute the receipt value missingFullEpochs times
					while(missingFullEpochs > 0) {
						poolInfo.receiptValue += poolInfo.receiptValue * eraInfos[i].rewardScaleFactor / _PERCENTAGE_SCALE;
						missingFullEpochs--;
					}

					// as _now was into the given era, we can stop the current loop here
					break;
				}
				// if it is in a different era then proceed using the eraEndingTime to compute the number of epochs left to
				// include in the current era and then proceed with the next value
				else {
					// NOTE: here some epochs may get lost as lastUpdateTime will almost never be equal to the exact epoch
					// 		update time, in order to avoid this error we compute the difference from the lastUpdateTime
					//		and the difference from the start of this era, as the two value will differ most of the times
					//		we compute the real number of epoch from the last fully completed one
					uint256 diffSinceEraEnd = eraEndingTime - lastUpdateTime;
					uint256 epochsSinceEraEnd = diffSinceEraEnd / _EPOCH_DURATION;

					uint256 diffSinceEraStart = eraEndingTime - eraInfos[i].startingTime;
					uint256 epochsSinceEraStart = diffSinceEraStart / _EPOCH_DURATION;

					uint256 missingFullEpochs;

					if(epochsSinceEraStart > epochsSinceEraEnd) {
						missingFullEpochs = epochsSinceEraStart - epochsSinceEraEnd;
					}

					// recompute the receipt value missingFullEpochs times
					while(missingFullEpochs > 0) {
						poolInfo.receiptValue += poolInfo.receiptValue * eraInfos[i].rewardScaleFactor / _PERCENTAGE_SCALE;
						missingFullEpochs--;
					}
				}
			}
		}

		emit ReceiptValueUpdate(poolInfo.receiptValue);
	}

	/**
		Increase the reward pool of this contract of _amount.
		Funds gets withdrawn from the caller address

		@param _amount MELD to insert into the reward pool
	 */
	function increaseRewardPool(uint256 _amount) public onlyOwner nonReentrant {
		prng.rotate();

		require(_amount > 0, "Unable to deposit null amount");
		require(melodity.balanceOf(msg.sender) >= _amount, "Not enough balance to stake");
		require(melodity.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

		melodity.transferFrom(msg.sender, address(this), _amount);
		poolInfo.rewardPool += _amount;

		_checkIfExhausting();
		emit RewardPoolIncreased(_amount);
	}

	/**
		Update the era duration and trigger the regeneration of 5 era infos

		@param _epochsNumber Number of epoch an era should last
	 */
	function updateEraDuration(uint256 _epochsNumber) public onlyOwner nonReentrant {
		uint256 old = poolInfo.genesisEraDuration;
		poolInfo.genesisEraDuration = _epochsNumber * _EPOCH_DURATION;
		_triggerErasInfoRefresh(5);
		emit EraDurationUpdate(old, poolInfo.genesisEraDuration);
	}

	/**
		Trigger the refresh of _eraAmount era infos

		@param _eraAmount Number of eras to refresh
	 */
	function refreshErasInfo(uint8 _eraAmount) public onlyOwner nonReentrant {
		_triggerErasInfoRefresh(_eraAmount);
	}

	/**
		Update the reward scaling factor

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%

		@param _factor Percentage of the reward scaling factor
		@param _erasToRefresh Number of eras to refresh immediately starting from the next one
	 */
	function updateRewardScaleFactor(uint256 _factor, uint8 _erasToRefresh) public onlyOwner nonReentrant {
		uint256 old = poolInfo.genesisEraDuration;
		poolInfo.genesisRewardScaleFactor = _factor;
		_triggerErasInfoRefresh(_erasToRefresh);
		emit RewardScalingFactorUpdate(old, poolInfo.genesisEraDuration);
	}

	/**
		Update the era scaling factor

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%

		@param _factor Percentage of the era scaling factor
		@param _erasToRefresh Number of eras to refresh immediately starting from the next one
	 */
	function updateEraScaleFactor(uint256 _factor, uint8 _erasToRefresh) public onlyOwner nonReentrant {
		uint256 old = poolInfo.genesisEraScaleFactor;
		poolInfo.genesisEraScaleFactor = _factor;
		_triggerErasInfoRefresh(_erasToRefresh);
		emit EraScalingFactorUpdate(old, poolInfo.genesisEraScaleFactor);
	}

	/**
		Update the fee percentage applied to users withdrawing funds earlier

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%
		@notice The factor must be a value between feeInfo.minFeePercentage and feeInfo.maxFeePercentage

		@param _percent Percentage of the fee
	 */
	function updateEarlyWithdrawFeePercent(uint256 _percent) public onlyOwner nonReentrant {
		require(_percent >= feeInfo.minFeePercentage, "Early withdraw fee too low");
		require(_percent <= feeInfo.maxFeePercentage, "Early withdraw fee too high");

		uint256 old = feeInfo.feePercentage;
		feeInfo.feePercentage = _percent;
		emit EarlyWithdrawFeeUpdate(old, feeInfo.feePercentage);
	}

	/**
		Update the fee receiver (where all dao's fee are sent)

		@notice This address should always be the dao's address

		@param _dao Address of the fee receiver
	 */
	function updateFeeReceiverAddress(address _dao) public onlyOwner nonReentrant {
		require(_dao != address(0), "Provided address is invalid");

		address old = feeInfo.feeReceiver;
		feeInfo.feeReceiver = _dao;
		emit FeeReceiverUpdate(old, feeInfo.feeReceiver);
	}

	/**
		Update the withdraw period that a deposit is considered to be early

		@notice The period must be a value between 1 and 7 days

		@param _period Number or days or hours of the fee period
		@param _isDay Whether the provided period is in hours or in days
	 */
	function updateWithdrawFeePeriod(uint256 _period, bool _isDay) public onlyOwner nonReentrant {
		if(_isDay) {
			// days (max 7 days, min 1 day)
			require(_period <= 7, "Withdraw period too long");
			require(_period >= 1, "Withdraw period too short");
			uint256 old = feeInfo.withdrawFeePeriod;
			uint256 day = 1 days;
			feeInfo.withdrawFeePeriod = _period * day;
			emit WithdrawPeriodUpdate(old, feeInfo.withdrawFeePeriod);
		}
		else {
			// hours (max 7 days, min 1 day)
			require(_period <= 168, "Withdraw period too long");
			require(_period >= 24, "Withdraw period too short");
			uint256 old = feeInfo.withdrawFeePeriod;
			uint256 hour = 1 hours;
			feeInfo.withdrawFeePeriod = _period * hour;
			emit WithdrawPeriodUpdate(old, feeInfo.withdrawFeePeriod);
		}
	}

	/**
		Update the share of the fee that is sent to the dao

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%
		@notice The percentage must be a value between feeInfo.feeReceiverMinPercent and 
				100 ether - feeInfo.feeMaintainerMinPercent

		@param _percent Percentage of the fee to send to the dao
	 */
	function updateDaoFeePercentage(uint256 _percent) public onlyOwner nonReentrant {
		require(_percent >= feeInfo.feeReceiverMinPercent, "Dao's fee share too low");
		require(_percent <= 100 ether - feeInfo.feeMaintainerMinPercent, "Dao's fee share too high");

		uint256 old = feeInfo.feeReceiverPercentage;
		feeInfo.feeReceiverPercentage = _percent;
		feeInfo.feeMaintainerPercentage = 100 ether - _percent;
		emit DaoFeeSharedUpdate(old, feeInfo.feeReceiverPercentage);
		emit MaintainerFeeSharedUpdate(100 ether - old, feeInfo.feeMaintainerPercentage);
	}

	/**
		Update the fee percentage applied to users withdrawing funds earlier

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%
		@notice The percentage must be a value between feeInfo.feeMaintainerMinPercent and 
				100 ether - feeInfo.feeReceiverMinPercent

		@param _percent Percentage of the fee to send to the maintainers
	 */
	function updateMaintainerFeePercentage(uint256 _percent) public onlyOwner nonReentrant {
		require(_percent >= feeInfo.feeMaintainerMinPercent, "Maintainer's fee share too low");
		require(_percent <= 100 ether - feeInfo.feeReceiverMinPercent, "Maintainer's fee share too high");

		uint256 old = feeInfo.feeMaintainerPercentage;
		feeInfo.feeMaintainerPercentage = _percent;
		feeInfo.feeReceiverPercentage = 100 ether - _percent;
		emit MaintainerFeeSharedUpdate(old, feeInfo.feeMaintainerPercentage);
		emit DaoFeeSharedUpdate(100 ether - old, feeInfo.feeReceiverPercentage);
	}
}
