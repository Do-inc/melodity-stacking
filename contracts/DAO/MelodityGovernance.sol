// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MelodityGovernance is ERC20, ERC20Permit, ERC20Votes, ERC20Wrapper, Ownable {
	address public dao;

    constructor(IERC20 wrappedToken)
        ERC20("Melodity governance", "gMELD")
        ERC20Permit("Melodity governance")
        ERC20Wrapper(wrappedToken)
    {}

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

	function updateDAO(address _dao) public onlyOwner {
		dao = _dao;
	}

	function recover() public returns (uint256) {
		uint256 value = underlying.balanceOf(address(this)) - totalSupply();
		_mint(dao, value);
		return value;
	}
}