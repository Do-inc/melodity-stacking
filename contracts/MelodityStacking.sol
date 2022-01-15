// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IPRNG.sol";
import "./PRNG.sol";
import "hardhat/console.sol";

contract MelodityStacking is IPRNG, ReentrancyGuard {
    uint256 public rewardPool = 20_000_000 ether;
	uint256 public baseRewardPerEpoch;
	uint256 public epochDuration = 1 hours;
	uint256 public eraDuration = 2500 * epochDuration;
	uint256 public rewardScaleFactor = 90 ether;
	uint256 public eraScaleFactor = 110 ether;

    ERC20 melodity;
    PRNG prng;

    bool initialized;

    bytes4 constant _INTERFACE_ID_ERC20_METADATA = 0x942e8b22;

    function initialize(address _masterchef, address _melodity)
        public
        nonReentrant
    {
        require(!initialized, "Contract already initialized");
        require(
            // check the SC supports the ERC20 & ERC20_METADATA openzeppelin interface
            ERC165Checker.supportsInterface(_melodity, _INTERFACE_ID_ERC20_METADATA),
            "The provided address does not seem to implement the ERC20 token standard"
        );

		initialized = true;

		prng = PRNG(computePRNGAddress(_masterchef));
		melodity = ERC20(_melodity);
    }

    function refreshRewardPool() public {}
}
