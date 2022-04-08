// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

abstract contract EmergencyWithdraw {
    address constant public DO_INC_MULTISIG_WALLET = 0x01Af10f1343C05855955418bb99302A6CF71aCB8;

    /// Withdraw some locked funds into a contract
    event eWithdraw(address token, uint256 amount);

    /**
        Allows for the withdraw of funds locked into the contract
     */
    function emergencyWithdraw(address token, uint256 amount) public virtual returns(bool) {
        // if a token address is provided withdraw that token amount
        if(token != address(0)) {
            ERC20 utility_token = ERC20(token);

            if(amount > 0) {
                _emergencyWithdraw(utility_token, amount);
            }
            else {
                amount = utility_token.balanceOf(address(this));
                _emergencyWithdraw(utility_token, amount);
            }
        }
        // if no token address is provided withdraw native currency
        else {
            if(amount > 0) {
                Address.sendValue(payable(DO_INC_MULTISIG_WALLET), amount);
            }
            else {
                Address.sendValue(payable(DO_INC_MULTISIG_WALLET), address(this).balance);
            }
        }

        return true;
    }

    function _emergencyWithdraw(ERC20 token, uint256 amount) private returns(bool) {
        token.transfer(DO_INC_MULTISIG_WALLET, amount);
        emit eWithdraw(address(token), amount);
        return true;
    }
}