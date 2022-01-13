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

const deployMarketplace = async (prng) => {
	const Marketplace = await ethers.getContractFactory("TestableMarketplace");
	const marketplace = await Marketplace.deploy(prng);
	return await marketplace.deployed();
};

const timetravel = async (seconds = 60) => {
	await network.provider.send("evm_increaseTime", [seconds]);
	await network.provider.send("evm_mine");
};

describe("Marketplace", function () {
	let stacking_panda,
		prng,
		marketplace,
		tx,
		abi_coder,
		dead_address = `0x${"0".repeat(36)}dead`,
		null_address = `0x${"0".repeat(40)}`;

	beforeEach(async function () {
		[owner, acc_1, acc_2] = await ethers.getSigners();

		prng = await deployPRNG();
		stacking_panda = await deployStackingPanda(prng.address);
		marketplace = await deployMarketplace(prng.address);
		abi_coder = ethers.utils.defaultAbiCoder;
	});

	it("everyone can create auction", async function () {
		const StackingPanda = await ethers.getContractFactory(
			"TestableStackingPanda"
		);
		stacking_panda = await StackingPanda.connect(acc_1).deploy(
			prng.address
		);
		await stacking_panda.deployed();

		tx = await stacking_panda
			.connect(acc_1)
			.mint("test-nft", "https://example.com", {
				decimals: 18,
				meldToMeld: ethers.utils.parseEther("1.0"),
				toMeld: ethers.utils.parseEther("1.0"),
			});
		await tx.wait();

		expect(await stacking_panda.balanceOf(acc_1.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(acc_1.address);

		tx = await stacking_panda
			.connect(acc_1)
			.approve(marketplace.address, 0);
		await tx.wait();

		tx = await marketplace.connect(acc_1).createAuctionWithRoyalties(
			0,
			stacking_panda.address,
			acc_1.address,
			60, // 60s
			ethers.utils.parseEther("0.1"),
			0,
			acc_1.address,
			null_address
		);
		await tx.wait();

		let auction = await marketplace.auctions(0);

		expect(await stacking_panda.balanceOf(acc_1.address)).to.equals(0);
		expect(await stacking_panda.balanceOf(auction)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(auction);
	});
	it("cannot start auction without previous approval", async function () {
		const StackingPanda = await ethers.getContractFactory(
			"TestableStackingPanda"
		);
		stacking_panda = await StackingPanda.connect(acc_1).deploy(
			prng.address
		);
		await stacking_panda.deployed();

		tx = await stacking_panda
			.connect(acc_1)
			.mint("test-nft", "https://example.com", {
				decimals: 18,
				meldToMeld: ethers.utils.parseEther("1.0"),
				toMeld: ethers.utils.parseEther("1.0"),
			});
		await tx.wait();

		expect(await stacking_panda.balanceOf(acc_1.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(acc_1.address);

		try {
			tx = await marketplace.connect(acc_1).createAuctionWithRoyalties(
				0,
				stacking_panda.address,
				acc_1.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				0,
				acc_1.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Trasfer not allowed for Marketplace operator'"
			);
		}
	});
	it("cannot start auction if not owning the NFT", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		tx = await stacking_panda.approve(marketplace.address, 0);
		await tx.wait();

		try {
			tx = await marketplace.connect(acc_1).createAuctionWithRoyalties(
				0,
				stacking_panda.address,
				acc_1.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				0,
				acc_1.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Not owning the provided NFT'"
			);
		}
	});
	it("cannot set a royalty higher than 50% with auctions", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		tx = await stacking_panda.approve(marketplace.address, 0);
		await tx.wait();

		try {
			tx = await marketplace.createAuctionWithRoyalties(
				0,
				stacking_panda.address,
				owner.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				ethers.utils.parseEther("51.0"),
				owner.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Royalty percentage too high, max value is 50%'"
			);
		}
	});
	it("cannot create auction if address does not implement ERC721", async function () {
		try {
			tx = await marketplace.createAuctionWithRoyalties(
				0,
				dead_address,
				owner.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				ethers.utils.parseEther("50.0"),
				owner.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'The provided address does not seem to implement the ERC721 NFT standard'"
			);
		}
	});
	it("everyone can create blind auction", async function () {
		const StackingPanda = await ethers.getContractFactory(
			"TestableStackingPanda"
		);
		stacking_panda = await StackingPanda.connect(acc_1).deploy(
			prng.address
		);
		await stacking_panda.deployed();

		tx = await stacking_panda
			.connect(acc_1)
			.mint("test-nft", "https://example.com", {
				decimals: 18,
				meldToMeld: ethers.utils.parseEther("1.0"),
				toMeld: ethers.utils.parseEther("1.0"),
			});
		await tx.wait();

		expect(await stacking_panda.balanceOf(acc_1.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(acc_1.address);

		tx = await stacking_panda
			.connect(acc_1)
			.approve(marketplace.address, 0);
		await tx.wait();

		tx = await marketplace.connect(acc_1).createBlindAuctionwithRoyalties(
			0,
			stacking_panda.address,
			acc_1.address,
			60, // 60s
			ethers.utils.parseEther("0.1"),
			0,
			acc_1.address,
			null_address
		);
		await tx.wait();

		let auction = await marketplace.blindAuctions(0);

		expect(await stacking_panda.balanceOf(acc_1.address)).to.equals(0);
		expect(await stacking_panda.balanceOf(auction)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(auction);
	});
	it("cannot start blind auction without previous approval", async function () {
		const StackingPanda = await ethers.getContractFactory(
			"TestableStackingPanda"
		);
		stacking_panda = await StackingPanda.connect(acc_1).deploy(
			prng.address
		);
		await stacking_panda.deployed();

		tx = await stacking_panda
			.connect(acc_1)
			.mint("test-nft", "https://example.com", {
				decimals: 18,
				meldToMeld: ethers.utils.parseEther("1.0"),
				toMeld: ethers.utils.parseEther("1.0"),
			});
		await tx.wait();

		expect(await stacking_panda.balanceOf(acc_1.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(acc_1.address);

		try {
			tx = await marketplace.connect(acc_1).createBlindAuctionwithRoyalties(
				0,
				stacking_panda.address,
				acc_1.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				0,
				acc_1.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Trasfer not allowed for Marketplace operator'"
			);
		}
	});
	it("cannot start blind auction if not owning the NFT", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		tx = await stacking_panda.approve(marketplace.address, 0);
		await tx.wait();

		try {
			tx = await marketplace.connect(acc_1).createBlindAuctionwithRoyalties(
				0,
				stacking_panda.address,
				acc_1.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				0,
				acc_1.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Not owning the provided NFT'"
			);
		}
	});
	it("cannot set a royalty higher than 50% with blind auctions", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		tx = await stacking_panda.approve(marketplace.address, 0);
		await tx.wait();

		try {
			tx = await marketplace.createBlindAuctionwithRoyalties(
				0,
				stacking_panda.address,
				owner.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				ethers.utils.parseEther("51.0"),
				owner.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Royalty percentage too high, max value is 50%'"
			);
		}
	});
	it("cannot create blind auction if address does not implement ERC721", async function () {
		try {
			tx = await marketplace.createBlindAuctionwithRoyalties(
				0,
				dead_address,
				owner.address,
				60, // 60s
				ethers.utils.parseEther("0.1"),
				ethers.utils.parseEther("50.0"),
				owner.address,
				null_address
			);
			await tx.wait();
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'The provided address does not seem to implement the ERC721 NFT standard'"
			);
		}
	});
	it("everyone can read royalties value", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		tx = await stacking_panda.approve(marketplace.address, 0);
		await tx.wait();

		tx = await marketplace.createAuctionWithRoyalties(
			0,
			stacking_panda.address,
			owner.address,
			60, // 60s
			ethers.utils.parseEther("0.1"),
			ethers.utils.parseEther("25.0"),
			owner.address,
			null_address
		);
		await tx.wait();

		let abi_packed_data = abi_coder.encode(
			["address", "uint256"],
			[stacking_panda.address, 0]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);

		let tmp_royalties = await marketplace.royalties(encoded_abi);
		let royalties = {
			decimals: tmp_royalties["decimals"],
			royaltyPercent: tmp_royalties["royaltyPercent"],
			royaltyReceiver: tmp_royalties["royaltyReceiver"],
			royaltyInitializer: tmp_royalties["royaltyInitializer"],
		};
		let expected = {
			decimals: 18,
			royaltyPercent: ethers.utils.parseEther("25.0"),
			royaltyReceiver: owner.address,
			royaltyInitializer: owner.address,
		};

		expect(royalties.decimals).to.equals(expected.decimals);
		expect(royalties.royaltyPercent).to.equals(expected.royaltyPercent);
		expect(royalties.royaltyReceiver).to.equals(expected.royaltyReceiver);
		expect(royalties.royaltyInitializer).to.equals(
			expected.royaltyInitializer
		);
	});
	it("creator can update its royalty", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		tx = await stacking_panda.approve(marketplace.address, 0);
		await tx.wait();

		tx = await marketplace.createAuctionWithRoyalties(
			0,
			stacking_panda.address,
			owner.address,
			60, // 60s
			ethers.utils.parseEther("0.1"),
			ethers.utils.parseEther("25.0"),
			owner.address,
			null_address
		);
		await tx.wait();

		tx = await marketplace.updateRoyalty(
			0,
			stacking_panda.address,
			ethers.utils.parseEther("50.0"),
			owner.address,
			null_address
		);
		await tx;
		
		let abi_packed_data = abi_coder.encode(
			["address", "uint256"],
			[stacking_panda.address, 0]
		);
		let encoded_abi = ethers.utils.keccak256(abi_packed_data);

		let tmp_royalties = await marketplace.royalties(encoded_abi);
		let royalties = {
			decimals: tmp_royalties["decimals"],
			royaltyPercent: tmp_royalties["royaltyPercent"],
			royaltyReceiver: tmp_royalties["royaltyReceiver"],
			royaltyInitializer: tmp_royalties["royaltyInitializer"],
		};
		let expected = {
			decimals: 18,
			royaltyPercent: ethers.utils.parseEther("50.0"),
			royaltyReceiver: owner.address,
			royaltyInitializer: owner.address,
		};

		expect(royalties.decimals).to.equals(expected.decimals);
		expect(royalties.royaltyPercent).to.equals(expected.royaltyPercent);
		expect(royalties.royaltyReceiver).to.equals(expected.royaltyReceiver);
		expect(royalties.royaltyInitializer).to.equals(
			expected.royaltyInitializer
		);
	});
	it("other cannot update non owned royalty", async function () {
		tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx.wait();

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		tx = await stacking_panda.approve(marketplace.address, 0);
		await tx.wait();

		tx = await marketplace.createAuctionWithRoyalties(
			0,
			stacking_panda.address,
			owner.address,
			60, // 60s
			ethers.utils.parseEther("0.1"),
			ethers.utils.parseEther("25.0"),
			owner.address,
			dead_address
		);
		await tx.wait();

		try {
			tx = await marketplace.updateRoyalty(
				0,
				stacking_panda.address,
				ethers.utils.parseEther("50.0"),
				owner.address,
				null_address
			);
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'You're not the owner of the royalty'"
			);
		}
	});
});
