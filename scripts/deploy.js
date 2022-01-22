// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
	/**
     * Network: Binance Smart Chain (BSC)     
     * Melodity Bep20: 0x13E971De9181eeF7A4aEAEAA67552A6a4cc54f43

	 * Network: Binance Smart Chain TESTNET (BSC)     
     * Melodity Bep20: 0x5EaA8Be0ebe73C0B6AdA8946f136B86b92128c55
     */
	let [caller] = await ethers.getSigners(),
		masterchef,
		melodityGovernance,
		prng,
		stackingPanda,
		marketplace,
		melodityDAOTimelock,
		melodityDAO,
		melodityStacking,
		melodityStackingReceipt,
		tx,
		meld = "0x13E971De9181eeF7A4aEAEAA67552A6a4cc54f43",
		proposerRole =
			"0xb09aa5aeb3702cfd50b6b62bc4532604938f21248a27a1d5ca736082b6819cc1",
		adminRole =
			"0x5f58e3a2316349923ce3780f8d587db2d72378aed66a8261c916544fa6846ca5";

	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	await hre.run("compile");

	console.log("[ ] Deploying Masterchef ...");
	const Masterchef = await hre.ethers.getContractFactory("Masterchef");
	masterchef = await Masterchef.deploy({
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await masterchef.deployed();
	console.log("[+] Deploying Masterchef");

	console.log("[ ] Deploying Melodity Governance ...");
	const MelodityGovernance = await hre.ethers.getContractFactory(
		"MelodityGovernance"
	);
	melodityGovernance = await MelodityGovernance.deploy(meld, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await melodityGovernance.deployed();
	console.log("[+] Deploying Melodity Governance");

	// deploy dao timelock
	console.log("[ ] Deploying Melodity DAO Timelock ...");
	const MelodityDAOTimelock = await hre.ethers.getContractFactory(
		"MelodityDAOTimelock"
	);
	melodityDAOTimelock = await MelodityDAOTimelock.deploy(
		[],
		[`0x${"0".repeat(40)}`],
		{
			gasLimit: 10_000_000,
			gasPrice: 10_000_000_000,
		}
	);
	await melodityDAOTimelock.deployed();
	console.log("[+] Deploying Melodity DAO Timelock");

	console.log("[ ] Deploying Melodity DAO ...");
	const MelodityDAO = await hre.ethers.getContractFactory("MelodityDAO");
	melodityDAO = await MelodityDAO.deploy(
		melodityGovernance.address,
		melodityDAOTimelock.address,
		{
			gasLimit: 10_000_000,
			gasPrice: 10_000_000_000,
		}
	);
	await melodityDAO.deployed();
	console.log("[+] Deploying Melodity DAO");

	console.log("[ ] Deploying Melodity Stacking ...");
	const MelodityStacking = await hre.ethers.getContractFactory(
		"MelodityStacking"
	);
	melodityStacking = await MelodityStacking.deploy(
		await masterchef.prng(),
		await masterchef.stackingPanda(),
		meld,
		melodityDAOTimelock.address,
		10,
		{
			gasLimit: 10_000_000,
			gasPrice: 10_000_000_000,
		}
	);
	await melodityStacking.deployed();
	console.log("[+] Deploying Melodity Stacking");

	console.log("[ ] Completing contracts setup ...");
	// retrieve masterchef addresses
	prng = await masterchef.prng();
	stackingPanda = await masterchef.stackingPanda();
	marketplace = await masterchef.marketplace();
	masterchef = masterchef.address;

	// retrieve dao addresses
	melodityDAO = melodityDAO.address;

	// complete the setup of the timelock
	tx = await melodityDAOTimelock.grantRole(proposerRole, melodityDAO, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	tx = await melodityDAOTimelock.renounceRole(adminRole, caller.address, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	melodityDAOTimelock = melodityDAOTimelock.address;

	// complete the setup of the governance token
	tx = await melodityGovernance.updateDAO(melodityDAOTimelock, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	tx = await melodityGovernance.renounceOwnership({
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	melodityGovernance = melodityGovernance.address;

	// complete the setup of the stacking
	tx = await melodityStacking.transferOwnership(melodityDAOTimelock, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	melodityStackingReceipt = await melodityStacking.stackingReceipt();
	melodityStacking = melodityStacking.address;
	console.log("[+] Completing contracts setup\n\n");

	console.group("Published contract addresses:");
	console.log("masterchef:", masterchef);
	console.log("melodityGovernance:", melodityGovernance);
	console.log("prng:", prng);
	console.log("stackingPanda:", stackingPanda);
	console.log("marketplace:", marketplace);
	console.log("melodityDAOTimelock:", melodityDAOTimelock);
	console.log("melodityDAO:", melodityDAO);
	console.log("melodityStacking:", melodityStacking);
	console.log("melodityStackingReceipt:", melodityStackingReceipt);
	console.groupEnd();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exitCode = 1;
	});
