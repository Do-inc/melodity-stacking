//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./PRNG.sol";

abstract contract IPRNG {
    function computePRNGAddress(address _masterchef) internal pure returns (address) {
        return
            Create2.computeAddress(
                keccak256("Masterchef/PRNG"),
                keccak256(type(PRNG).creationCode),
                _masterchef
            );
    }
}
