//SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./StackingPanda.sol";

abstract contract IStackingPanda {
    function computeStackingPandaAddress(address _masterchef) internal pure returns (address) {
        return
            Create2.computeAddress(
                keccak256("Masterchef/StackingPanda"),
                keccak256(type(StackingPanda).creationCode),
                _masterchef
            );
    }
}
