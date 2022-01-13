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

describe("Stacking Panda", function () {
	let stacking_panda, prng;
	null_address = `0x${"0".repeat(40)}`;

	beforeEach(async function () {
		[owner, acc_1, acc_2] = await ethers.getSigners();

		prng = await deployPRNG();
		stacking_panda = await deployStackingPanda(prng.address);
	});

	it("owner should be able to mint", async function () {
		let tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx;

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);
	});
	it("external account should not be able to mint", async function () {
		let tx;
		try {
			tx = await stacking_panda
				.connect(acc_1)
				.mint("test-nft", "https://example.com", {
					decimals: 18,
					meldToMeld: ethers.utils.parseEther("1.0"),
					toMeld: ethers.utils.parseEther("1.0"),
				});
			await tx;
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'Ownable: caller is not the owner'"
			);
		}
	});
	it("can be minted at most 100 nfts", async function () {
		let tx;
		try {
			// call the minting function 101 times
			for (let i = 0; i < 101; i++) {
				tx = await stacking_panda.mint(
					"test-nft",
					"https://example.com",
					{
						decimals: 18,
						meldToMeld: ethers.utils.parseEther("1.0"),
						toMeld: ethers.utils.parseEther("1.0"),
					}
				);
				await tx;
			}
		} catch (e) {
			expect(e.message).to.equals(
				"VM Exception while processing transaction: reverted with reason string " +
					"'All pandas minted'"
			);
		}
	});
	it("everyone can get metadata", async function () {
		let tx = await stacking_panda.mint("test-nft", "https://example.com", {
			decimals: 18,
			meldToMeld: ethers.utils.parseEther("1.0"),
			toMeld: ethers.utils.parseEther("1.0"),
		});
		await tx;

		expect(await stacking_panda.balanceOf(owner.address)).to.equals(1);
		expect(await stacking_panda.ownerOf(0)).to.equals(owner.address);

		let tmp_metadata = await stacking_panda.getMetadata(0);
		let metadata = {
			name: tmp_metadata["name"],
			picUrl: tmp_metadata["picUrl"],
			bonus: {
				decimals: tmp_metadata["bonus"]["decimals"],
				meldToMeld: tmp_metadata["bonus"]["meldToMeld"],
				toMeld: tmp_metadata["bonus"]["toMeld"],
			},
		};
		let expected = {
			name: "test-nft",
			picUrl: "https://example.com",
			bonus: {
				decimals: 18,
				meldToMeld: ethers.utils.parseEther("1.0"),
				toMeld: ethers.utils.parseEther("1.0"),
			},
		};

		expect(metadata.name).to.equals(expected.name);
		expect(metadata.picUrl).to.equals(expected.picUrl);
		expect(metadata.bonus.decimals).to.equals(expected.bonus.decimals);
		expect(metadata.bonus.meldToMeld).to.equals(expected.bonus.meldToMeld);
		expect(metadata.bonus.toMeld).to.equals(expected.bonus.toMeld);
	});
});
