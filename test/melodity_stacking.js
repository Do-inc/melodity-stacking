const chai = require("chai");
chai.use(require("chai-bignumber")());
const { expect } = chai;
const { ethers } = require("hardhat");

const deployPRNG = async () => {
	const PRNG = await ethers.getContractFactory("PRNG");
	const prng = await PRNG.deploy();
	return await prng.deployed();
};

const deployStackingPanda = async (prng) => {
	const StackingPanda = await ethers.getContractFactory(
		"TestableStackingPanda"
	);
	const stackingPanda = await StackingPanda.deploy(prng);
	return await stackingPanda.deployed();
};

const loadMelodityReceipt = async (address) => {
	const StackingPanda = await ethers.getContractFactory("StackingReceipt");
	return await StackingPanda.attach(address);
};

const deployFakeMelodity = async () => {
	const FakeMelodity = await ethers.getContractFactory("StackingReceipt");
	const melodity = await FakeMelodity.deploy("Melodity", "MELD");
	return await melodity.deployed();
};

const deployMelodityStacking = async (
	prng,
	stacking_panda,
	melodity,
	dao,
	reward_pool = ethers.utils.parseEther("20000000.0"),
	receipt_value = ethers.utils.parseEther("1.0"),
	genesis_era_duration = 720,
	genesis_reward_scale_factor = ethers.utils.parseEther("79.0"),
	genesis_era_scale_factor = ethers.utils.parseEther("107.0"),
	exhausting = false,
	dismissed = false,
	eras_to_generate = 10
) => {
	const MelodityStacking = await ethers.getContractFactory(
		"TestableMelodityStacking"
	);
	const melodity_stacking = await MelodityStacking.deploy(
		prng,
		stacking_panda,
		melodity,
		dao,
		reward_pool,
		receipt_value,
		genesis_era_duration,
		(genesis_reward_scale_factor = ethers.utils.parseEther("79.0")),
		genesis_era_scale_factor,
		exhausting,
		dismissed,
		eras_to_generate
	);
	return await melodity_stacking.deployed();
};

const timetravel = async (seconds = 60) => {
	await network.provider.send("evm_increaseTime", [seconds]);
	await network.provider.send("evm_mine");
};

describe("Melodity stacking", function () {
	let stacking_panda,
		prng,
		melodity,
		melodity_stacking,
		stacking_receipt,
		tx,
		dao,
		dead_address = `0x${"0".repeat(36)}dead`,
		null_address = `0x${"0".repeat(40)}`;

	beforeEach(async function () {
		[owner, acc_1, acc_2, dao] = await ethers.getSigners();

		prng = await deployPRNG();
		stacking_panda = await deployStackingPanda(prng.address);
		melodity = await deployFakeMelodity();
		melodity_stacking = await deployMelodityStacking(
			prng.address,
			stacking_panda.address,
			melodity.address,
			dao.address
		);
		stacking_receipt = await loadMelodityReceipt(
			await melodity_stacking.stackingReceipt()
		);

		await melodity.mint(melodity_stacking.address, ethers.utils.parseEther("20000000.0"))

		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("7.5"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();
		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		melodity.mint(owner.address, ethers.utils.parseEther("1000.0"));
		melodity.mint(acc_1.address, ethers.utils.parseEther("1000.0"));
		melodity.mint(acc_2.address, ethers.utils.parseEther("1000.0"));
	});

	it("era info gets correctly generated", async function () {
		let era_infos_length = await melodity_stacking.getEraInfosLength();
		expect(era_infos_length).to.equals(10);

		let era_infos = [];
		for (let i = 0; i < era_infos_length; i++) {
			let tmp_era_infos = await melodity_stacking.eraInfos(i);
			era_infos.push({
				startingTime: tmp_era_infos["startingTime"],
				eraDuration: tmp_era_infos["eraDuration"],
				rewardScaleFactor: tmp_era_infos["rewardScaleFactor"],
				eraScaleFactor: tmp_era_infos["eraScaleFactor"],
				rewardFactorPerEpoch: tmp_era_infos["rewardFactorPerEpoch"],
			});
		}

		let last_timestamp = (await melodity_stacking.poolInfo())[
				"genesisTime"
			],
			last_era_duration = (await melodity_stacking.poolInfo())[
				"genesisEraDuration"
			],
			last_era_upgrade_factor = (await melodity_stacking.poolInfo())[
				"genesisEraScaleFactor"
			],
			last_reward_upgrade_factor = (await melodity_stacking.poolInfo())[
				"genesisRewardScaleFactor"
			],
			last_reward_factor_per_epoch = (await melodity_stacking.poolInfo())[
				"genesisRewardFactorPerEpoch"
			];

		for (let i = 0; i < era_infos.length; i++) {
			expect(era_infos[i].startingTime).to.equals(+last_timestamp + 1);
			expect(era_infos[i].rewardScaleFactor).to.equals(
				last_reward_upgrade_factor
			);
			expect(era_infos[i].eraScaleFactor).to.equals(
				last_era_upgrade_factor
			);

			if (i === 0) {
				expect(era_infos[i].eraDuration).to.equals(last_era_duration);
			} else {
				expect(era_infos[i].eraDuration).to.equals(
					(BigInt(last_era_duration.toString()) *
						BigInt(last_era_upgrade_factor.toString())) /
						BigInt(`1${"0".repeat(20)}`)
				);

				last_era_duration =
					(BigInt(last_era_duration.toString()) *
						BigInt(last_era_upgrade_factor.toString())) /
					BigInt(`1${"0".repeat(20)}`);
			}

			last_timestamp = (
				BigInt(last_timestamp) +
				BigInt(1) +
				BigInt(last_era_duration.toString())
			).toString();
			last_era_upgrade_factor = last_era_upgrade_factor;
			last_reward_upgrade_factor = last_reward_upgrade_factor;

			if (i === 0) {
				expect(era_infos[i].rewardFactorPerEpoch).to.equals(
					last_reward_factor_per_epoch
				);
			} else {
				expect(era_infos[i].rewardFactorPerEpoch).to.equals(
					(BigInt(last_reward_factor_per_epoch) *
						BigInt(last_reward_upgrade_factor)) /
						BigInt(`1${"0".repeat(20)}`)
				);

				last_reward_factor_per_epoch =
					(BigInt(last_reward_factor_per_epoch) *
						BigInt(last_reward_upgrade_factor)) /
					BigInt(`1${"0".repeat(20)}`);
			}
		}
	});
	it("everyone can deposit in the stacking pool", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("100.0")
		);
		await tx;

		tx = await melodity_stacking.deposit(ethers.utils.parseEther("100.0"));
		await tx;

		expect(await stacking_receipt.balanceOf(owner.address)).to.equals(
			BigInt(ethers.utils.parseEther("100.0").toString())
		);
	});
	it("deposit requires prior approval", async function () {
		try {
			tx = await melodity_stacking.deposit(
				ethers.utils.parseEther("100.0")
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Allowance too low'"
			);
		}
	});
	it("cannot deposit null amount", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("100.0")
		);
		await tx;

		try {
			tx = await melodity_stacking.deposit(
				ethers.utils.parseEther("0.0")
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Unable to deposit null amount'"
			);
		}
	});
	it("cannot deposit more than what's owned", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("10000.0")
		);
		await tx;

		try {
			tx = await melodity_stacking.deposit(
				ethers.utils.parseEther("10000.0")
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Not enough balance to stake'"
			);
		}
	});
	it("each epoch the receipt value increases", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await melodity
			.connect(acc_1)
			.approve(
				melodity_stacking.address,
				ethers.utils.parseEther("1000.0")
			);
		await tx;

		tx = await melodity_stacking.deposit(ethers.utils.parseEther("100.0"));
		await tx;

		let first_rate = BigInt(
			(await melodity_stacking.poolInfo())["receiptValue"].toString()
		);

		await timetravel(3601);

		tx = await melodity_stacking
			.connect(acc_1)
			.deposit(ethers.utils.parseEther("100.0"));
		await tx;

		let second_rate = BigInt(
			(await melodity_stacking.poolInfo())["receiptValue"].toString()
		);

		let first_bought = await stacking_receipt.balanceOf(owner.address);
		let second_bought = await stacking_receipt.balanceOf(acc_1.address);

		expect(first_bought.toString()).to.be.bignumber.greaterThan(
			second_bought.toString()
		);
		expect(first_rate.toString()).to.be.bignumber.lessThan(
			second_rate.toString()
		);
		expect(first_rate.toString()).to.equals("1000000000000000000");
		expect(second_rate.toString()).to.equals("1000010000000000000");
	});
	it("everyone can deposit with NFT", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await stacking_panda.approve(melodity_stacking.address, 0);
		await tx;

		tx = await melodity_stacking.depositWithNFT(
			ethers.utils.parseEther("100.0"),
			0
		);
		await tx;

		expect(await stacking_receipt.balanceOf(owner.address)).to.equals(
			ethers.utils.parseEther("107.5").toString()
		);
		expect(await melodity_stacking.depositorNFT(0)).to.equals(owner.address)
		expect((await melodity_stacking.stackedNFTs(owner.address, 0))["nftId"]).to.equals(0)
		expect((await melodity_stacking.stackedNFTs(owner.address, 0))["stackedAmount"]).to.equals(ethers.utils.parseEther("107.5").toString())
	});
	it("cannot deposit with not owned NFT", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("7.5"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();
		tx = await stacking_panda.transferFrom(owner.address, acc_1.address, 1)
		await tx.wait();

		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		try {
			tx = await melodity_stacking.depositWithNFT(
				ethers.utils.parseEther("100.0"),
				1
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'You're not the owner of the provided NFT'"
			);
		}
	});
	it("cannot deposit without prior allowing the NFT", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		try {
			tx = await melodity_stacking.depositWithNFT(
				ethers.utils.parseEther("100.0"),
				0
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Stacking pool not allowed to withdraw your NFT'"
			);
		}
	});
	it("everyone can withdraw", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await stacking_receipt.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await melodity_stacking.deposit(
			ethers.utils.parseEther("100.0"),
		);
		await tx;

		await timetravel(1000000)	// 7+ days

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		let rate = BigInt(
			(await melodity_stacking.poolInfo())["receiptValue"].toString()
		);
		expect(rate.toString()).to.equals("1002773826106451450");

		let bought = await stacking_receipt.balanceOf(owner.address);
		expect(bought).to.equals(ethers.utils.parseEther("100.0"))

		tx = await melodity_stacking.withdraw(bought)
		await tx

		let remaining_receipt = await stacking_receipt.balanceOf(owner.address);
		expect(remaining_receipt).to.equals(0)

		let melodity_balance = await melodity.balanceOf(owner.address)
		expect(melodity_balance).to.equals("1000555534632417172700")
	});
	it("cannot withdraw null amount", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		try {
			tx = await melodity_stacking.withdraw(
				0
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Nothing to withdraw'"
			);
		}
	});
	it("cannot withdraw more receipt than the owned", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		try {
			tx = await melodity_stacking.withdraw(
				100
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Not enought receipt to widthdraw'"
			);
		}
	});
	it("cannot withdraw without prior approval", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await stacking_receipt.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await melodity_stacking.deposit(
			ethers.utils.parseEther("100.0"),
		);
		await tx;

		await timetravel(1000000)	// 7+ days

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		try {
			tx = await melodity_stacking.withdraw(
				100
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Stacking pool not allowed to withdraw enough of you receipt'"
			);
		}
	});
	it("redeeming before 7 days trigger fee payment", async function () {
		tx = await melodity.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await stacking_receipt.approve(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0")
		);
		await tx;

		tx = await melodity_stacking.deposit(
			ethers.utils.parseEther("100.0"),
		);
		await tx;

		await timetravel(1000000)	// 7+ days

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		let rate = BigInt(
			(await melodity_stacking.poolInfo())["receiptValue"].toString()
		);
		expect(rate.toString()).to.equals("1002773826106451450");

		let bought = await stacking_receipt.balanceOf(owner.address);
		expect(bought).to.equals(ethers.utils.parseEther("100.0"))

		tx = await melodity_stacking.withdraw(bought)
		await tx

		let remaining_receipt = await stacking_receipt.balanceOf(owner.address);
		expect(remaining_receipt).to.equals(0)

		let melodity_balance = await melodity.balanceOf(owner.address)
		expect(melodity_balance).to.equals("1000555534632417172700")
	});
});
