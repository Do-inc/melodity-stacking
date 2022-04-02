require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("hardhat-abi-exporter");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
	const accounts = await hre.ethers.getSigners();

	for (const account of accounts) {
		console.log(account.address);
	}
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
	solidity: {
		version: "0.8.11",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
	networks: {
		ropsten: {
			url: process.env.ROPSTEN_URL || "",
			accounts:
				process.env.PRIVATE_KEY !== undefined
					? [process.env.PRIVATE_KEY]
					: [],
		},
		tbsc: {
			url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
			accounts:
				process.env.PRIVATE_KEY !== undefined
					? [process.env.PRIVATE_KEY]
					: [],
			chainId: 97,
			gas: 100_000_000,
			gasPrice: 10000000000,
		},
		bsc: {
			url: "https://bsc-dataseed.binance.org/",
			accounts:
				process.env.PRIVATE_KEY !== undefined
					? [process.env.PRIVATE_KEY]
					: [],
			chainId: 56,
			gas: 100_000_000,
			gasPrice: 10000000000,
		},
		tfantom: {
			url: "https://rpc.testnet.fantom.network/",
			accounts:
				process.env.PRIVATE_KEY !== undefined
					? [process.env.PRIVATE_KEY]
					: [],
			chainId: 4002,
			gas: 100_000_000,
			gasPrice: 10000000000,
		},
		fantom: {
			url: "https://rpc.ftm.tools/",
			accounts:
				process.env.PRIVATE_KEY !== undefined
					? [process.env.PRIVATE_KEY]
					: [],
			chainId: 250,
			gas: 100_000_000,
			gasPrice: 10000000000,
		},
	},
	gasReporter: {
		enabled: process.env.REPORT_GAS !== undefined,
		currency: "USD",
		gasPriceApi:
			"https://api.bscscan.com/api?module=proxy&action=eth_gasPrice",
		coinmarketcap: process.env.CMC,
		token: "BNB",
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_API_KEY,
	},
	abiExporter: {
		runOnCompile: true,
		clear: true,
		spacing: 4,
		pretty: false,
	},
};
