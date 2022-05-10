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
		genesis_reward_scale_factor,
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
	const _DO_INC_MULTISIG_WALLET =
		"0x01Af10f1343C05855955418bb99302A6CF71aCB8";
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

		await melodity.mint(
			melodity_stacking.address,
			ethers.utils.parseEther("20000000.0")
		);

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
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("100.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		// 3 internal calls to function with fees
		tx = await melodity_stacking.deposit(ethers.utils.parseEther("100.0"), {
			value: ethers.utils.parseEther("0.0005").toString()
		});
		await tx;

		expect(await stacking_receipt.balanceOf(owner.address)).to.equals(
			BigInt(ethers.utils.parseEther("100.0").toString())
		);
	});
	it("deposit requires prior approval", async function () {
		try {
			tx = await melodity_stacking.deposit(
				ethers.utils.parseEther("100.0"), {
					value: ethers.utils.parseEther("0.0005").toString()
				}
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'ERC20: insufficient allowance'"
			);
		}
	});
	it("cannot deposit null amount", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("100.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		try {
			tx = await melodity_stacking.deposit(
				ethers.utils.parseEther("0.0"), {
					value: ethers.utils.parseEther("0.0005").toString()
				}
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
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("10000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		try {
			tx = await melodity_stacking.deposit(
				ethers.utils.parseEther("10000.0"), {
					value: ethers.utils.parseEther("0.0005").toString()
				}
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'ERC20: transfer amount exceeds balance'"
			);
		}
	});
	it("each epoch the receipt value increases", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await melodity
			.connect(acc_1)
			.approveWithFee(
				melodity_stacking.address,
				ethers.utils.parseEther("1000.0"), {
					value: ethers.utils.parseEther("0.0005").toString()
				}
			);
		await tx;

		tx = await melodity_stacking.deposit(ethers.utils.parseEther("100.0"), {
			value: ethers.utils.parseEther("0.0005").toString()
		});
		await tx;

		let first_rate = BigInt(
			(await melodity_stacking.poolInfo())["receiptValue"].toString()
		);

		await timetravel(3601);

		tx = await melodity_stacking
			.connect(acc_1)
			.deposit(ethers.utils.parseEther("100.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			});
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
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_panda.approve(melodity_stacking.address, 0);
		await tx;

		tx = await melodity_stacking.depositWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		expect(await stacking_receipt.balanceOf(owner.address)).to.equals(
			ethers.utils.parseEther("107.5").toString()
		);
		expect(await melodity_stacking.depositorNFT(0)).to.equals(
			owner.address
		);
		expect(
			(await melodity_stacking.stackedNFTs(owner.address, 0))["nftId"]
		).to.equals(0);
		expect(
			(await melodity_stacking.stackedNFTs(owner.address, 0))[
				"stackedAmount"
			]
		).to.equals(ethers.utils.parseEther("107.5").toString());
	});
	it("cannot deposit with not owned NFT", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("7.5"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();
		tx = await stacking_panda.transferFrom(owner.address, acc_1.address, 1);
		await tx.wait();

		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		try {
			tx = await melodity_stacking.depositWithNFT(
				ethers.utils.parseEther("100.0"),
				1, {
					value: ethers.utils.parseEther("0.0005").toString()
				}
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'ERC721: transfer caller is not owner nor approved'"
			);
		}
	});
	it("cannot deposit without prior allowing the NFT", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		try {
			tx = await melodity_stacking.depositWithNFT(
				ethers.utils.parseEther("100.0"),
				0, {
					value: ethers.utils.parseEther("0.0005").toString()
				}
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'ERC721: transfer caller is not owner nor approved'"
			);
		}
	});
	it("everyone can withdraw", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await melodity_stacking.deposit(ethers.utils.parseEther("100.0"), {
			value: ethers.utils.parseEther("0.0005").toString()
		});
		await tx;

		await timetravel(1000000); // 7+ days

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		let rate = BigInt(
			(await melodity_stacking.poolInfo())["receiptValue"].toString()
		);
		expect(rate.toString()).to.equals("1002773826106451450");

		let bought = await stacking_receipt.balanceOf(owner.address);
		expect(bought).to.equals(ethers.utils.parseEther("100.0"));

		tx = await melodity_stacking.withdraw(bought, {
			value: ethers.utils.parseEther("0.0005").toString()
		});
		await tx;

		let remaining_receipt = await stacking_receipt.balanceOf(owner.address);
		expect(remaining_receipt).to.equals(0);

		let melodity_balance = await melodity.balanceOf(owner.address);
		expect(melodity_balance.toString()).to.equals("1000277382610645145000");
	});
	it("cannot withdraw null amount", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		try {
			tx = await melodity_stacking.withdraw(0, {
				value: ethers.utils.parseEther("0.0005").toString()
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Nothing to withdraw'"
			);
		}
	});
	it("cannot withdraw more receipt than the owned", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		try {
			tx = await melodity_stacking.withdraw(100, {
				value: ethers.utils.parseEther("0.0005").toString()
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'ERC20: insufficient allowance'"
			);
		}
	});
	it("cannot withdraw without prior approval", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await melodity_stacking.deposit(ethers.utils.parseEther("100.0"), {
			value: ethers.utils.parseEther("0.0005").toString()
		});
		await tx;

		await timetravel(1000000); // 7+ days

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		try {
			tx = await melodity_stacking.withdraw(100, {
				value: ethers.utils.parseEther("0.0005").toString()
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Stacking pool not allowed to withdraw enough of you receipt'"
			);
		}
	});
	it("redeeming before 7 days trigger fee payment", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await melodity_stacking.deposit(ethers.utils.parseEther("100.0"), {
			value: ethers.utils.parseEther("0.0005").toString()
		});
		await tx;

		await timetravel(5 * 60 * 60 + 1); // 5h

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		let rate = BigInt(
			(await melodity_stacking.poolInfo())["receiptValue"].toString()
		);
		expect(rate.toString()).to.equals("1000050001000010000");

		let bought = await stacking_receipt.balanceOf(owner.address);
		expect(bought).to.equals(ethers.utils.parseEther("100.0"));

		tx = await melodity_stacking.withdraw(bought, {
			value: ethers.utils.parseEther("0.0005").toString()
		});
		await tx;

		let remaining_receipt = await stacking_receipt.balanceOf(owner.address);
		expect(remaining_receipt).to.equals(0);

		let melodity_balance = await melodity.balanceOf(owner.address);
		expect(melodity_balance).to.equals("990004500090000900000"); // 990.004500090000900000

		melodity_balance = await melodity.balanceOf(_DO_INC_MULTISIG_WALLET);
		expect(melodity_balance).to.equals("9500475009500095000"); // 9.500475009500095000

		melodity_balance = await melodity.balanceOf(dao.address);
		expect(melodity_balance).to.equals("500025000500005000"); // 0.500025000500005000
	});
	it("can withdraw with NFT", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_panda.approve(melodity_stacking.address, 0);
		await tx;

		tx = await melodity_stacking.depositWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		await timetravel(1000000); // 7+ days

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		expect(await stacking_receipt.balanceOf(owner.address)).to.equals(
			ethers.utils.parseEther("107.5").toString()
		);
		expect(await melodity_stacking.depositorNFT(0)).to.equals(
			owner.address
		);
		expect(await stacking_panda.ownerOf(0)).to.equals(
			melodity_stacking.address
		);

		tx = await melodity_stacking.withdrawWithNFT(
			ethers.utils.parseEther("107.5"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		expect(await melodity_stacking.depositorNFT(0)).to.equals(null_address);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);
	});
	it("withdrawing less than the receipt amount received does not release the NFT", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_panda.approve(melodity_stacking.address, 0);
		await tx;

		tx = await melodity_stacking.depositWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		await timetravel(1000000); // 7+ days

		tx = await melodity_stacking.refreshReceiptValue();
		await tx;

		expect(await stacking_receipt.balanceOf(owner.address)).to.equals(
			ethers.utils.parseEther("107.5")
		);
		expect(await melodity_stacking.depositorNFT(0)).to.equals(
			owner.address
		);
		expect(await stacking_panda.ownerOf(0)).to.equals(
			melodity_stacking.address
		);

		tx = await melodity_stacking.withdrawWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		expect(await stacking_receipt.balanceOf(owner.address)).to.equals(
			ethers.utils.parseEther("7.5")
		);
		expect(await melodity_stacking.depositorNFT(0)).to.equals(
			owner.address
		);
		expect(
			(await melodity_stacking.stackedNFTs(owner.address, 0))[
				"stackedAmount"
			]
		).to.equals(ethers.utils.parseEther("7.5"));
		expect(await stacking_panda.ownerOf(0)).to.equals(
			melodity_stacking.address
		);
	});
	it("cannot withdraw a random index", async function () {
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_panda.approve(melodity_stacking.address, 0);
		await tx;

		tx = await melodity_stacking.depositWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		try {
			tx = await melodity_stacking.withdrawWithNFT(
				ethers.utils.parseEther("100.0"),
				10, {
					value: ethers.utils.parseEther("0.0005").toString()
				}
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Index out of bound'"
			);
		}
	});
	it("if pool exhausting alert works", async function () {
		melodity_stacking = await deployMelodityStacking(
			prng.address,
			stacking_panda.address,
			melodity.address,
			dao.address,
			ethers.utils.parseEther("1000.0")
		);
		stacking_receipt = await loadMelodityReceipt(await melodity_stacking.stackingReceipt())

		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await stacking_panda.approve(melodity_stacking.address, 0);
		await tx;

		tx = await melodity_stacking.depositWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await melodity_stacking.withdrawWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		expect((await melodity_stacking.poolInfo())["exhausting"]).to.equals(true)
	});
	it("can increase reward pool", async function () {
		let old = BigInt((await melodity_stacking.poolInfo())["rewardPool"].toString()).toString()

		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;

		tx = await melodity_stacking.increaseRewardPool(
			ethers.utils.parseEther("1.0")
		);
		await tx;

		let after = BigInt((await melodity_stacking.poolInfo())["rewardPool"].toString()).toString()
		
		expect(after).to.be.bignumber.greaterThan(old)
	});
	it("can refresh era info", async function () {
		let era_infos_length = await melodity_stacking.getEraInfosLength();
		expect(era_infos_length).to.equals(10);

		tx = await melodity_stacking.refreshErasInfo(
			10
		);
		await tx;

		era_infos_length = await melodity_stacking.getEraInfosLength();
		expect(era_infos_length).to.equals(11);
	});
	it("can update reward scale factor", async function () {
		let current_era_index = +(await melodity_stacking.getCurrentEraIndex())
		let old = BigInt((await melodity_stacking.eraInfos(current_era_index))["rewardScaleFactor"].toString()).toString()

		tx = await melodity_stacking.updateRewardScaleFactor(
			ethers.utils.parseEther("1.0"),
			1
		);
		await tx;

		let after = BigInt((await melodity_stacking.eraInfos(current_era_index))["rewardScaleFactor"].toString()).toString()

		expect(after).to.be.bignumber.lessThan(old)
	});
	it("can update era scale factor", async function () {
		let current_era_index = +(await melodity_stacking.getCurrentEraIndex())
		let old = BigInt((await melodity_stacking.eraInfos(current_era_index))["eraScaleFactor"].toString()).toString()

		tx = await melodity_stacking.updateEraScaleFactor(
			ethers.utils.parseEther("1.0"),
			1
		);
		await tx;

		let after = BigInt((await melodity_stacking.eraInfos(current_era_index))["eraScaleFactor"].toString()).toString()

		expect(after).to.be.bignumber.lessThan(old)
	});
	it("can update early withdraw fee percent", async function () {
		let old = BigInt((await melodity_stacking.feeInfo())["feePercentage"].toString()).toString()

		tx = await melodity_stacking.updateEarlyWithdrawFeePercent(
			ethers.utils.parseEther("1.0")
		);
		await tx;

		let after = BigInt((await melodity_stacking.feeInfo())["feePercentage"].toString()).toString()

		expect(after).to.be.bignumber.lessThan(old)

		try {
			tx = await await melodity_stacking.updateEarlyWithdrawFeePercent(
				ethers.utils.parseEther("100.0")
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Early withdraw fee too high'"
			);
		}
		try {
			tx = await await melodity_stacking.updateEarlyWithdrawFeePercent(
				0
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Early withdraw fee too low'"
			);
		}
	});
	it("can update fee receiver address", async function () {
		let old = BigInt((await melodity_stacking.feeInfo())["feeReceiver"].toString()).toString()

		tx = await melodity_stacking.updateFeeReceiverAddress(
			acc_2.address
		);
		await tx;

		let after = BigInt((await melodity_stacking.feeInfo())["feeReceiver"].toString()).toString()

		expect(after).to.be.bignumber.lessThan(old)

		try {
			tx = await await melodity_stacking.updateFeeReceiverAddress(
				null_address
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Provided address is invalid'"
			);
		}
	});
	it("can update withdraw fee period", async function () {
		let old = BigInt((await melodity_stacking.feeInfo())["withdrawFeePeriod"].toString()).toString()

		tx = await melodity_stacking.updateWithdrawFeePeriod(
			2,
			true
		);
		await tx;

		let after = BigInt((await melodity_stacking.feeInfo())["withdrawFeePeriod"].toString()).toString()
		
		tx = await melodity_stacking.updateWithdrawFeePeriod(
			24,
			false
		);
		await tx;

		old = after	
		after = BigInt((await melodity_stacking.feeInfo())["withdrawFeePeriod"].toString()).toString()

		expect(after).to.be.bignumber.lessThan(old)

		try {
			tx = await await melodity_stacking.updateWithdrawFeePeriod(
				0,
				true
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Withdraw period too short'"
			);
		}
		try {
			tx = await await melodity_stacking.updateWithdrawFeePeriod(
				100,
				true
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Withdraw period too long'"
			);
		}
		try {
			tx = await await melodity_stacking.updateWithdrawFeePeriod(
				0,
				false
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Withdraw period too short'"
			);
		}
		try {
			tx = await await melodity_stacking.updateWithdrawFeePeriod(
				1000,
				false
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Withdraw period too long'"
			);
		}
	});
	it("can update maintainer's fee percent", async function () {
		let old = BigInt((await melodity_stacking.feeInfo())["feeReceiverPercentage"].toString()).toString()
		let old_maintainer = BigInt((await melodity_stacking.feeInfo())["feeMaintainerPercentage"].toString()).toString()

		tx = await melodity_stacking.updateDaoFeePercentage(
			ethers.utils.parseEther("10.0")
		);
		await tx;

		let after = BigInt((await melodity_stacking.feeInfo())["feeReceiverPercentage"].toString()).toString()
		let after_maintainer = BigInt((await melodity_stacking.feeInfo())["feeMaintainerPercentage"].toString()).toString()

		expect(after).to.equal(ethers.utils.parseEther("10.0"))
		expect(after_maintainer).to.equal(ethers.utils.parseEther("90.0"))

		try {
			tx = await await melodity_stacking.updateDaoFeePercentage(
				ethers.utils.parseEther("100.0")
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Dao's fee share too high'"
			);
		}
		try {
			tx = await await melodity_stacking.updateDaoFeePercentage(
				0
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Dao's fee share too low'"
			);
		}
	});
	it("can update dao's fee percent", async function () {
		let old = BigInt((await melodity_stacking.feeInfo())["feeReceiverPercentage"].toString()).toString()
		let old_maintainer = BigInt((await melodity_stacking.feeInfo())["feeMaintainerPercentage"].toString()).toString()

		tx = await melodity_stacking.updateMaintainerFeePercentage(
			ethers.utils.parseEther("25.0")
		);
		await tx;

		let after = BigInt((await melodity_stacking.feeInfo())["feeReceiverPercentage"].toString()).toString()
		let after_maintainer = BigInt((await melodity_stacking.feeInfo())["feeMaintainerPercentage"].toString()).toString()

		expect(after).to.be.bignumber.greaterThan(old)
		expect(after_maintainer).to.be.bignumber.lessThan(old_maintainer)
		expect(after).to.equal(ethers.utils.parseEther("75.0"))
		expect(after_maintainer).to.equal(ethers.utils.parseEther("25.0"))

		try {
			tx = await await melodity_stacking.updateMaintainerFeePercentage(
				ethers.utils.parseEther("100.0")
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Maintainer's fee share too high'"
			);
		}
		try {
			tx = await await melodity_stacking.updateMaintainerFeePercentage(
				0
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Maintainer's fee share too low'"
			);
		}
	});
	it("can pause and resume", async function () {
		let old = await melodity_stacking.paused()

		tx = await melodity_stacking.pause();
		await tx;

		let after = await melodity_stacking.paused()

		expect(after).to.equals(!old)
		expect(after).to.equals(true)

		tx = await melodity_stacking.resume();
		await tx;

		old = after
		after = await melodity_stacking.paused()

		expect(after).to.equals(!old)
		expect(after).to.equals(false)
	});
	it("can run dismission withdraw", async function () {
		melodity_stacking = await deployMelodityStacking(
			prng.address,
			stacking_panda.address,
			melodity.address,
			dao.address,
			ethers.utils.parseEther("1000.0")
		);
		stacking_receipt = await loadMelodityReceipt(await melodity_stacking.stackingReceipt())

		await melodity.mint(
			melodity_stacking.address,
			ethers.utils.parseEther("20000000.0")
		);

		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx.wait();

		tx = await stacking_receipt.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther("1000.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx.wait();

		tx = await stacking_panda.approve(melodity_stacking.address, 0);
		await tx.wait();

		tx = await melodity_stacking.depositWithNFT(
			ethers.utils.parseEther("100.0"),
			0, {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx.wait();

		await timetravel(1000000); // 7+ days

		let old = await melodity_stacking.paused()

		tx = await melodity_stacking.pause();
		await tx.wait();

		let after = await melodity_stacking.paused()

		expect(after).to.equals(!old)
		expect(after).to.equals(true)

		tx = await melodity_stacking.resume();
		await tx.wait();

		tx = await melodity_stacking.withdraw(ethers.utils.parseEther("107.5"), {
			value: ethers.utils.parseEther("0.0005").toString()
		})
		await tx.wait()

		expect(await stacking_panda.ownerOf(0)).to.equals(melodity_stacking.address)

		tx = await melodity_stacking.pause();
		await tx.wait();

		tx = await melodity_stacking.dismissionWithdraw()
		await tx.wait()

		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address)
	});
	it("refreshReceiptValue don't loses eras", async function () {
		await timetravel(60*60*24)

		tx = await melodity_stacking.refreshReceiptValue();
		await tx.wait();

		expect((await melodity_stacking.poolInfo())["lastComputedEra"]).to.equal(0)

		let old_receipt_value = (await melodity_stacking.poolInfo())["receiptValue"],
			new_receipt_value

		await timetravel(31*60*60*24)
		tx = await melodity_stacking.refreshReceiptValue();
		await tx.wait();

		new_receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]

		expect((await melodity_stacking.poolInfo())["lastComputedEra"]).to.equal(1)

		expect(new_receipt_value.toString()).to.be.bignumber.greaterThan(old_receipt_value.toString())
		expect(new_receipt_value.toString()).to.be.bignumber.greaterThan("1007200000000000000")
		expect(new_receipt_value.toString()).to.be.bignumber.lessThan("1018250000000000000")

		await timetravel(40*60*60*24)
		tx = await melodity_stacking.refreshReceiptValue();
		await tx.wait();

		new_receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]

		expect((await melodity_stacking.poolInfo())["lastComputedEra"]).to.equal(2)

		expect(new_receipt_value.toString()).to.be.bignumber.greaterThan(old_receipt_value.toString())
		expect(new_receipt_value.toString()).to.be.bignumber.greaterThan("1007200000000000000")
		expect(new_receipt_value.toString()).to.be.bignumber.lessThan("1018250000000000000")
	});
	it("refreshReceiptValue increases value per epoch", async function () {
		let receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
		expect(receipt_value).to.equals("1000000000000000000")

		let calls = 100
		// in the first epoch seems to work wisely, no receipt value update with multiple calls
		for(let i = 0; i < calls; i++) {
			tx = await melodity_stacking.refreshReceiptValue()
			await tx.wait()
			receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
			expect(receipt_value).to.equals("1000000000000000000")
		}

		// move a day in the future
		await timetravel(60*60*24)
		/* console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("TIME TRAVEL +24H")
		console.log("-".repeat(50)) */

		// first refresh should move the receipt value forward 
		tx = await melodity_stacking.refreshReceiptValue()
		await tx.wait()
		receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
		expect(receipt_value).to.equals("1000240027602024097")

		/* console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("FIRST UPDATE AT +24H DONE")
		console.log("-".repeat(50)) */

		// repeated refresh should not move the value
		for(let i = 0; i < calls; i++) {
			tx = await melodity_stacking.refreshReceiptValue()
			await tx.wait()
			receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
			expect(receipt_value).to.equals("1000240027602024097")
		}

		// move a day in the future
		await timetravel(60*60*24)
		/* console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("TIME TRAVEL +48H")
		console.log("-".repeat(50)) */

		// first refresh should move the receipt value forward 
		tx = await melodity_stacking.refreshReceiptValue()
		await tx.wait()
		receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
		expect(receipt_value).to.equals("1000480112817297924")

		/* console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("FIRST UPDATE AT +48H DONE")
		console.log("-".repeat(50)) */

		// repeated refresh should not move the value
		for(let i = 0; i < calls; i++) {
			tx = await melodity_stacking.refreshReceiptValue()
			await tx.wait()
			receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
			expect(receipt_value).to.equals("1000480112817297924")
		}

		// as deposits also trigger the refresh checking deposits do not trigger it
		await melodity.mint(
			melodity_stacking.address,
			ethers.utils.parseEther(`${calls}.0`)
		);
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther(`${calls +1}.0`), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;
		for(let i = 0; i < calls; i++) {
			tx = await melodity_stacking.deposit(ethers.utils.parseEther("1.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			})
			await tx.wait()
			receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
			expect(receipt_value).to.equals("1000480112817297924")
		}

		await timetravel(60*60*24*32)
		/* console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("TIME TRAVEL +34d")
		console.log("-".repeat(50)) */

		// first refresh should move the receipt value forward 
		tx = await melodity_stacking.refreshReceiptValue()
		await tx.wait()
		receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
		expect(receipt_value).to.equals("1007980033134399774")
		let last_computed_era = (await melodity_stacking.poolInfo())["lastComputedEra"]
		expect(last_computed_era).to.equals("1")

		/* console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("-".repeat(50))
		console.log("FIRST UPDATE AT +34d DONE")
		console.log("-".repeat(50)) */

		// repeated refresh should not move the value
		for(let i = 0; i < calls; i++) {
			tx = await melodity_stacking.refreshReceiptValue()
			await tx.wait()
			receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
			expect(receipt_value).to.equals("1007980033134399774")
		}

		// as deposits also trigger the refresh checking deposits do not trigger it
		await melodity.mint(
			melodity_stacking.address,
			ethers.utils.parseEther(`${calls}.0`)
		);
		tx = await melodity.approveWithFee(
			melodity_stacking.address,
			ethers.utils.parseEther(`${calls +1}.0`), {
				value: ethers.utils.parseEther("0.0005").toString()
			}
		);
		await tx;
		for(let i = 0; i < calls; i++) {
			tx = await melodity_stacking.deposit(ethers.utils.parseEther("1.0"), {
				value: ethers.utils.parseEther("0.0005").toString()
			})
			await tx.wait()
			receipt_value = (await melodity_stacking.poolInfo())["receiptValue"]
			expect(receipt_value).to.equals("1007980033134399774")
		}
	});
	it("emergency withdraw allows withdraw of meld", async function () {
		melodity_stacking = await deployMelodityStacking(
			prng.address,
			stacking_panda.address,
			melodity.address,
			dao.address,
			ethers.utils.parseEther("10000000.0")
		);

		tx = await melodity.mint(melodity_stacking.address, ethers.utils.parseEther("1000.0"))
		await tx.wait()

		let balance = await melodity.balanceOf("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		tx = await melodity_stacking.emergencyWithdraw(melodity.address, 0)
		await tx.wait()

		let new_balance = await melodity.balanceOf("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		expect(new_balance).to.equals(balance.add(ethers.utils.parseEther("1000.0")))
	});
	it("emergency withdraw allows withdraw of 1 meld", async function () {
		melodity_stacking = await deployMelodityStacking(
			prng.address,
			stacking_panda.address,
			melodity.address,
			dao.address,
			ethers.utils.parseEther("10000000.0")
		);

		tx = await melodity.mint(melodity_stacking.address, ethers.utils.parseEther("1000.0"))
		await tx.wait()

		let balance = await melodity.balanceOf("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		tx = await melodity_stacking.emergencyWithdraw(melodity.address, 1)
		await tx.wait()

		let new_balance = await melodity.balanceOf("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		expect(new_balance).to.equals(balance.add(1))
	});
	it("emergency withdraw allows withdraw of native currency", async function () {
		melodity_stacking = await deployMelodityStacking(
			prng.address,
			stacking_panda.address,
			melodity.address,
			dao.address,
			ethers.utils.parseEther("10000000.0")
		);

		tx = await owner.sendTransaction({
			to: melodity_stacking.address, 
			value: ethers.utils.parseEther("10.0")
		})
		await tx.wait()

		let balance = await ethers.provider.getBalance("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		tx = await melodity_stacking.emergencyWithdraw(`0x${"0".repeat(40)}`, 0)
		await tx.wait()

		let new_balance = await ethers.provider.getBalance("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		expect(new_balance).to.equals(balance.add(ethers.utils.parseEther("10.0")))
	});
	it("emergency withdraw allows withdraw of 1 native currency", async function () {
		melodity_stacking = await deployMelodityStacking(
			prng.address,
			stacking_panda.address,
			melodity.address,
			dao.address,
			ethers.utils.parseEther("10000000.0")
		);

		tx = await owner.sendTransaction({
			to: melodity_stacking.address, 
			value: ethers.utils.parseEther("10.0")
		})
		await tx.wait()

		let balance = await ethers.provider.getBalance("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		tx = await melodity_stacking.emergencyWithdraw(`0x${"0".repeat(40)}`, 1)
		await tx.wait()

		let new_balance = await ethers.provider.getBalance("0x01Af10f1343C05855955418bb99302A6CF71aCB8")

		expect(new_balance).to.equals(balance.add(1))
	});
});
