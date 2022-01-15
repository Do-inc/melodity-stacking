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
	_biddingTime = 60
) => {
	const Auction = await ethers.getContractFactory("TestableAuction");
	const auction = await Auction.deploy(
		_biddingTime,
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

describe("Auction", function () {
	let stacking_panda,
		prng,
		auction,
		tx,
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

		tx = await auction.bid({
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		expect(await auction.highestBidder()).to.equals(owner.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.1")
		);

		tx = await auction.connect(acc_1).bid({
			value: ethers.utils.parseEther("0.11"),
		});
		await tx;

		expect(await auction.highestBidder()).to.equals(acc_1.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.11")
		);
		expect(await auction.pendingReturns(owner.address)).to.equals(
			ethers.utils.parseEther("0.1")
		);
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
		await timetravel(61);

		try {
			tx = await auction.bid({
				value: ethers.utils.parseEther("0.1"),
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Auction already ended'"
			);
		}
	});
	it("cannot bid under the minimum", async function () {
		auction = await deployAuction(
			prng.address,
			owner.address,
			0,
			stacking_panda.address,
			ethers.utils.parseEther("1"),
			owner.address,
			ethers.utils.parseEther("1")
		);
		await moveNFT(auction.address, stacking_panda);

		try {
			tx = await auction.bid({
				value: ethers.utils.parseEther("0.1"),
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Bid not high enough to participate in this auction'"
			);
		}
	});
	it("cannot bid lower or equal to the higher bid", async function () {
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

		tx = await auction.bid({
			value: ethers.utils.parseEther("0.2"),
		});
		await tx;

		try {
			tx = await auction.bid({
				value: ethers.utils.parseEther("0.1"),
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Higher or equal bid already present'"
			);
		}

		try {
			tx = await auction.bid({
				value: ethers.utils.parseEther("0.2"),
			});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Higher or equal bid already present'"
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

		tx = await auction.bid({
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		expect(await auction.highestBidder()).to.equals(owner.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.1")
		);

		tx = await auction.connect(acc_1).bid({
			value: ethers.utils.parseEther("0.11"),
		});
		await tx;

		expect(await auction.highestBidder()).to.equals(acc_1.address);
		expect(await auction.highestBid()).to.equals(
			ethers.utils.parseEther("0.11")
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

		tx = await auction.connect(acc_1).bid({
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		tx = await auction.connect(acc_2).bid({
			value: ethers.utils.parseEther("0.5"),
		});
		await tx;

		await timetravel(70);

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

		tx = await auction.connect(acc_1).bid({
			value: ethers.utils.parseEther("0.1"),
		});
		await tx;

		tx = await auction.connect(acc_2).bid({
			value: ethers.utils.parseEther("0.5"),
		});
		await tx;

		await timetravel(70);

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

		await timetravel(70);

		let old_owner_balance = await ethers.provider.getBalance(owner.address);

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
					"'Auction not ended yet'"
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

		await timetravel(70);

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
