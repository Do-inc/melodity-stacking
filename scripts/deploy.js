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

	console.log("meld", meld)
	console.log("proposerRole", proposerRole)
	console.log("adminRole", adminRole)

	console.log("[ ] Deploying Masterchef ...");
	const Masterchef = await hre.ethers.getContractFactory("Masterchef");
	/* masterchef = await Masterchef.deploy({
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	}); */
	masterchef = await Masterchef.attach("0x46303b92A45445F51529c6DD705FcF1A9F68E592");
	console.log("[+] Deploying Masterchef");
	console.log("masterchef", masterchef.address)

	console.log("[ ] Deploying Melodity Governance ...");
	const MelodityGovernance = await hre.ethers.getContractFactory(
		"MelodityGovernance"
	);
	/* melodityGovernance = await MelodityGovernance.deploy(meld, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	}); */
	melodityGovernance = await MelodityGovernance.attach("0xfCFE6E40B47FE7879Cf30180df157Df9e9e8AE33");
	console.log("[+] Deploying Melodity Governance");
	console.log("melodityGovernance", melodityGovernance.address)

	// deploy dao timelock
	// 0xeCEBB0572439F7B9D97EF31dc42efa6937385383
	console.log("[ ] Deploying Melodity DAO Timelock ...");
	const MelodityDAOTimelock = await hre.ethers.getContractFactory(
		"MelodityDAOTimelock"
	);
	/* melodityDAOTimelock = await MelodityDAOTimelock.deploy(
		[],
		[`0x${"0".repeat(40)}`],
		{
			gasLimit: 10_000_000,
			gasPrice: 10_000_000_000,
		}
	); */
	melodityDAOTimelock = await MelodityDAOTimelock.attach("0xeCEBB0572439F7B9D97EF31dc42efa6937385383");
	await melodityDAOTimelock.deployed();
	console.log("[+] Deploying Melodity DAO Timelock");
	console.log("melodityDAOTimelock", melodityDAOTimelock.address)

	console.log("[ ] Deploying Melodity DAO ...");
	// 0x7e0923D9483475B3Cf5aA926796ECa87CED9653c
	const MelodityDAO = await hre.ethers.getContractFactory("MelodityDAO");
	/* melodityDAO = await MelodityDAO.deploy(
		melodityGovernance.address,
		melodityDAOTimelock.address,
		45818,
		{
			gasLimit: 10_000_000,
			gasPrice: 10_000_000_000,
		}
	); */
	melodityDAO = await MelodityDAO.attach("0x7e0923D9483475B3Cf5aA926796ECa87CED9653c");
	console.log("[+] Deploying Melodity DAO");
	console.log("MelodityDAO", melodityDAO.address)

	console.log("[ ] Deploying Melodity Stacking ...");
	// 0xBBC7f6990BD35BbB2d6970f69616998790cA5614
	const MelodityStacking = await hre.ethers.getContractFactory(
		"MelodityStacking"
	);
	/* melodityStacking = await MelodityStacking.deploy(
		await masterchef.prng(),
		await masterchef.stackingPanda(),
		melodityGovernance.address,
		melodityDAOTimelock.address,
		10,
		{
			gasLimit: 10_000_000,
			gasPrice: 10_000_000_000,
		}
	); */
	melodityStacking = await MelodityStacking.attach("0xBBC7f6990BD35BbB2d6970f69616998790cA5614");
	console.log("[+] Deploying Melodity Stacking");
	console.log("melodityStacking", melodityStacking.address)
	console.log("await masterchef.prng()", await masterchef.prng())
	console.log("await masterchef.stackingPanda()", await masterchef.stackingPanda())

	console.log("[ ] Completing contracts setup ...");
	// retrieve masterchef addresses
	/* prng = await masterchef.prng();
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
	tx = await melodityGovernance.addToWhitelist(melodityDAOTimelock, true, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	tx = await melodityGovernance.addToWhitelist(melodityStacking.address, true, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	// ownership not renounced as the whitelist must be disabled at listing time and cannot
	// be limited to the dao (participation may be too low).
	// after listing time the ownership will be renounced, anyway owning the contract
	// does not give any special power like minting or similar
	melodityGovernance = melodityGovernance.address;

	// complete the setup of the stacking
	tx = await melodityStacking.transferOwnership(melodityDAOTimelock, {
		gasLimit: 10_000_000,
		gasPrice: 10_000_000_000,
	});
	await tx;
	melodityStackingReceipt = await melodityStacking.stackingReceipt();
	melodityStacking = melodityStacking.address;
	console.log("[+] Completing contracts setup\n\n");*/

	stackingPanda = await masterchef.stackingPanda();
	marketplace = await masterchef.marketplace();
	masterchef = masterchef.address;
	melodityDAO = melodityDAO.address;
	melodityDAOTimelock = melodityDAOTimelock.address
	melodityGovernance = melodityGovernance.address
	melodityStackingReceipt = await melodityStacking.stackingReceipt()
	melodityStacking = melodityStacking.address;

	console.group("Published contract addresses:");
	console.log("masterchef:", masterchef);
	console.log("melodityGovernance:", melodityGovernance);
	console.log("prng:", "0x256C62804B4D76758a1b6b9A01879BCCA3f42Bd3");
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
