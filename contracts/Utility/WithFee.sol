// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Address.sol";

abstract contract WithFee {
    address public withFee_feeReceiver;
    uint256 public withFee_feeBase;

    event WithFee_FeeBaseUpdate(uint256 amount);
    event WithFee_FeeReceiverUpdate(address receiver);
    event WithFee_FeeWithdrawn(uint256 amount);

    error UnableToPaySomeFees(uint256 fees);

    function setFeeBase(uint256 _amount) public virtual returns(bool) {
        withFee_feeBase = _amount;
        emit WithFee_FeeBaseUpdate(withFee_feeBase);
        return true;
    }

    function setFeeReceiver(address _receiver) public virtual returns(bool) {
        withFee_feeReceiver = _receiver;
        emit WithFee_FeeReceiverUpdate(withFee_feeReceiver);
        return true;
    }

    modifier withFee() {
        uint256 fee = (msg.value / 1 ether + 1) * withFee_feeBase;

        if(msg.value < fee) {
            revert UnableToPaySomeFees(fee);
        }

        Address.sendValue(payable(withFee_feeReceiver), fee);
        emit WithFee_FeeWithdrawn(fee);
        _;
    }
}