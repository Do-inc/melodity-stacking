// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "../Utility/WithFee.sol";

/**
	@author Emanuele (ebalo) Balsamo
	
	Stacking receipt contract developed to be easily instantiable with
	custom data.

	Most functions are reserved to the owner as this reduces the possibility
	to lock funds in stacking pools. 
	User can always transfer funds actually being able to use any aggregator,
	or yield optimizer.
 */
contract StackingReceipt is ERC20, ERC20Burnable, Ownable, WithFee {
  address constant public _DO_INC_MULTISIG_WALLET = 0x01Af10f1343C05855955418bb99302A6CF71aCB8;

  error MethodDisabled();

  constructor(string memory _name, string memory _ticker)
    ERC20(_name, _ticker)
  {
    setFeeBase(0.0005 ether);
		setFeeReceiver(_DO_INC_MULTISIG_WALLET);
  }

  function mint(address _to, uint256 _amount) public onlyOwner {
    _mint(_to, _amount);
  }

  function burn(uint256 _amount) public override onlyOwner {
    _burn(msg.sender, _amount);
  }

  function burnFrom(address _account, uint256 _amount)
    public
    override
    onlyOwner
  {
    ERC20Burnable.burnFrom(_account, _amount);
  }

  function approveWithFee(address spender, uint256 amount) public payable withFee returns (bool) {
    return ERC20.approve(spender, amount);
  }

  function approve(address spender, uint256 amount) public override returns(bool) {
    revert MethodDisabled();
  }
}
