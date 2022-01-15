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

const deployAuction = async (
	_prng,
	_beneficiaryAddress,
	_nftId,
	_nftContract,
	_minimumBid,
	_royaltyReceiver,
	_royaltyPercentage,
	_biddingTime = 60,
	_revealTime = 30
) => {
	const Auction = await ethers.getContractFactory("TestableBlindAuction");
	const auction = await Auction.deploy(
		_biddingTime,
		_revealTime,
		_beneficiaryAddress,
		_nftId,
		_nftContract,
		_minimumBid,
		_royaltyReceiver,
		_royaltyPercentage,
		_prng
	);
	return await auction.deployed();
};

const timetravel = async (seconds = 60) => {
	await network.provider.send("evm_increaseTime", [seconds]);
	await network.provider.send("evm_mine");
};

const moveNFT = async (address, stacking_panda) => {
	tx = await stacking_panda.transferFrom(owner.address, address, 0);
	await tx;
};

describe("Blind auction", function () {
	let stacking_panda,
		prng,
		auction,
		tx,
		abi_coder,
		dead_address = `0x${"0".repeat(36)}dead`,
		null_address = `0x${"0".repeat(40)}`;

	beforeEach(async function () {
		[owner, acc_1, acc_2] = await ethers.getSigners();

		prng = await deployPRNG();
		stacking_panda = await deployStackingPanda(prng.address);

		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();
		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		abi_coder = ethers.utils.defaultAbiCoder;
	});

	it("everyone can bid", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);

		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		let raw_bids = await auction.bids(owner.address, 0);
		let bid = {
			blindedBid: raw_bids["blindedBid"],
			deposit: raw_bids["deposit"],
		};
		let expected = {
			blindedBid: encoded_abi,
			deposit: ethers.utils.parseEther("0.1"),
		};

		expect(bid.blindedBid).to.equals(expected.blindedBid);
		expect(bid.deposit).to.equals(expected.deposit);
	});
	it("cannot bid an ended auction", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);
		timetravel(61);

		try {
			let abi_packed_data = abi_coder.encode(
				["uint256", "bool", "bytes32"],
				[
					ethers.utils.parseEther("0.1"),
					false,
					ethers.utils.keccak256(
						ethers.utils.toUtf8Bytes("password")
					),
				]
			);
			let encoded_abi = ethers.utils.keccak256(abi_packed_data);

			tx = await auction.bid(encoded_abi, {
				value: ethers.utils.parseEther("0.1"),
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Method called too late'"
			);
		}
	});
	it("can reveal blinded bids", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		await timetravel(61);

		tx = await auction.reveal(
			[ethers.utils.parseEther("0.1")],
			[false],
			[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
		);
		await tx;

		expect(await auction.highestBidder()).to.equals(owner.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.1")
		);
	});
	it("cannot reveal only a chunk of bids", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		await timetravel(61);

		try {
			tx = await auction.reveal(
				[ethers.utils.parseEther("0.1")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'You're not revealing all your bids'"
			);
		}
	});
	it("can reveal blinded bids using placeholders", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);

		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		await timetravel(61);

		tx = await auction.reveal(
			[ethers.utils.parseEther("0.1"), 0],
			[false, true],
			[
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		await tx;

		expect(await auction.highestBidder()).to.equals(owner.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.1")
		);

		let tmp_bid_0 = await auction.bids(owner.address, 0);
		let tmp_bid_1 = await auction.bids(owner.address, 1);
		let bid0 = {
			blindedBid: tmp_bid_0["blindedBid"],
			deposit: tmp_bid_0["deposit"],
		};
		let expected0 = {
			blindedBid: ethers.constants.HashZero,
			deposit: ethers.utils.parseEther("0.1"),
		};
		let bid1 = {
			blindedBid: tmp_bid_1["blindedBid"],
			deposit: tmp_bid_1["deposit"],
		};
		let expected1 = {
			blindedBid: encoded_abi,
			deposit: ethers.utils.parseEther("0.1"),
		};

		expect(bid0.blindedBid).to.equals(expected0.blindedBid);
		expect(bid0.deposit).to.equals(expected0.deposit);
		expect(bid1.blindedBid).to.equals(expected1.blindedBid);
		expect(bid1.deposit).to.equals(expected1.deposit);
	});
	it("refused bids gets refunded", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);

		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		await timetravel(61);

		let old_owner_balance = await ethers.provider.getBalance(owner.address);

		tx = await auction.reveal(
			[ethers.utils.parseEther("0.1"), ethers.utils.parseEther("0.1")],
			[false, false],
			[
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		await tx;

		expect(await auction.highestBidder()).to.equals(owner.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.1")
		);

		let owner_balance = (
			await ethers.provider.getBalance(owner.address)
		).toString();

		expect(owner_balance).to.be.bignumber.at.most(
			(
				BigInt(old_owner_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.1").toString())
			).toString()
		);
		expect(owner_balance).to.be.bignumber.at.least(
			(
				BigInt(old_owner_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.09").toString())
			).toString()
		);
	});
	it("cannot reveal before bidding is ended", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		try {
			tx = await auction.reveal(
				[ethers.utils.parseEther("0.1")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Method called too early'"
			);
		}
	});
	it("cannot reveal after reveal phase is ended", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		await timetravel(91);

		try {
			tx = await auction.reveal(
				[ethers.utils.parseEther("0.1")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Method called too late'"
			);
		}
	});
	it("can withdraw overbid bids", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);
		tx = await auction.bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.2"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		encoded_abi = ethers.utils.keccak256(abi_packed_data);

		tx = await auction.connect(acc_1).bid(encoded_abi, {
			value: ethers.utils.parseEther("0.2"),
		});
		await tx;

		await timetravel(61);

		tx = await auction.reveal(
			[ethers.utils.parseEther("0.1")],
			[false],
			[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
		);
		await tx;

		tx = await auction
			.connect(acc_1)
			.reveal(
				[ethers.utils.parseEther("0.2")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
		await tx;

		expect(await auction.highestBidder()).to.equals(acc_1.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.2")
		);
		expect(await auction.pendingReturns(owner.address)).to.equals(
			ethers.utils.parseEther("0.1")
		);

		let old_balance = await ethers.provider.getBalance(owner.address);

		tx = await auction.withdraw();
		await tx;
		expect(await auction.pendingReturns(owner.address)).to.equals(0);

		let balance = (
			await ethers.provider.getBalance(owner.address)
		).toString();
		expect(balance).to.be.bignumber.at.most(
			(
				BigInt(old_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.1").toString())
			).toString()
		);
		expect(balance).to.be.bignumber.at.least(
			(
				BigInt(old_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.09").toString())
			).toString()
		);
	});
	it("everyone can close a finished auction", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);
		tx = await auction.connect(acc_1).bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.5"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		encoded_abi = ethers.utils.keccak256(abi_packed_data);

		tx = await auction.connect(acc_2).bid(encoded_abi, {
			value: ethers.utils.parseEther("0.5"),
		});
		await tx;

		await timetravel(61);

		tx = await auction
			.connect(acc_1)
			.reveal(
				[ethers.utils.parseEther("0.1")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
		await tx;

		tx = await auction
			.connect(acc_2)
			.reveal(
				[ethers.utils.parseEther("0.5")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
		await tx;

		await timetravel(91);

		let old_owner_balance = await ethers.provider.getBalance(owner.address);

		tx = await auction.connect(acc_1).endAuction();
		await tx;

		expect(await stacking_panda.balanceOf(acc_2.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(acc_2.address);

		let owner_balance = (
			await ethers.provider.getBalance(owner.address)
		).toString();

		expect(owner_balance).to.be.bignumber.at.most(
			(
				BigInt(old_owner_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.5").toString())
			).toString()
		);
		expect(owner_balance).to.be.bignumber.at.least(
			(
				BigInt(old_owner_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.49").toString())
			).toString()
		);
	});
	it("finished auction distributes royalties", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			acc_1.address,
			ethers.utils.parseEther("50")
		);
		await moveNFT(auction.address, stacking_panda);

		let abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.1"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);
		tx = await auction.connect(acc_1).bid(encoded_abi, {
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		abi_packed_data = abi_coder.encode(
			["uint256", "bool", "bytes32"],
			[
				ethers.utils.parseEther("0.5"),
				false,
				ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password")),
			]
		);
		encoded_abi = ethers.utils.keccak256(abi_packed_data);

		tx = await auction.connect(acc_2).bid(encoded_abi, {
			value: ethers.utils.parseEther("0.5"),
		});
		await tx;

		await timetravel(61);

		tx = await auction
			.connect(acc_1)
			.reveal(
				[ethers.utils.parseEther("0.1")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
		await tx;

		tx = await auction
			.connect(acc_2)
			.reveal(
				[ethers.utils.parseEther("0.5")],
				[false],
				[ethers.utils.keccak256(ethers.utils.toUtf8Bytes("password"))]
			);
		await tx;

		await timetravel(91);

		let old_owner_balance = await ethers.provider.getBalance(owner.address);
		let old_acc1_balance = await ethers.provider.getBalance(acc_1.address);

		tx = await auction.connect(acc_1).endAuction();
		await tx;

		expect(await stacking_panda.balanceOf(acc_2.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(acc_2.address);

		let owner_balance = (
			await ethers.provider.getBalance(owner.address)
		).toString();
		let acc1_balance = (
			await ethers.provider.getBalance(acc_1.address)
		).toString();

		expect(owner_balance).to.be.bignumber.at.most(
			(
				BigInt(old_owner_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.25").toString())
			).toString()
		);
		expect(owner_balance).to.be.bignumber.at.least(
			(
				BigInt(old_owner_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.24").toString())
			).toString()
		);

		expect(acc1_balance).to.be.bignumber.at.most(
			(
				BigInt(old_acc1_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.25").toString())
			).toString()
		);
		expect(acc1_balance).to.be.bignumber.at.least(
			(
				BigInt(old_acc1_balance.toString()) +
				BigInt(ethers.utils.parseEther("0.20").toString())
			).toString()
		);
	});
	it("invalid auction ends sending nft to payee", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		await timetravel(91);

		tx = await auction.connect(acc_1).endAuction();
		await tx;

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);
	});
	it("cannot end auction before it's ended", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		try {
			tx = await auction.endAuction();
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Method called too early'"
			);
		}
	});
	it("cannot end auction more than one time", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("0.1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		await timetravel(91);

		tx = await auction.endAuction();
		await tx;

		try {
			tx = await auction.endAuction();
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Auction already ended'"
			);
		}
	});
});
