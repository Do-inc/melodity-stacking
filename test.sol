// Sources flattened with hardhat v2.8.0 https://hardhat.org

// File @openzeppelin/contracts/utils/Create2.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


// File @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File @openzeppelin/contracts/utils/Address.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// File @openzeppelin/contracts/utils/Context.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/token/ERC721/ERC721.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;







/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}


// File @openzeppelin/contracts/utils/Counters.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/PRNG.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract PRNG {
    int256 public seed;

    /**
        Retrive a new pseudo random number and rotate the seed.

        IMPORTANT:
        As stated in the official solidity 0.8.11 documentation in the first warning
        on top of the following permalink:
        https://docs.soliditylang.org/en/v0.8.11/abi-spec.html#encoding-of-indexed-event-parameters

        """
        If you use keccak256(abi.encodePacked(a, b)) and both a and b are dynamic types, it is easy 
        to craft collisions in the hash value by moving parts of a into b and vice-versa. More 
        specifically, abi.encodePacked("a", "bc") == abi.encodePacked("ab", "c"). If you use 
        abi.encodePacked for signatures, authentication or data integrity, make sure to always use 
        the same types and check that at most one of them is dynamic. Unless there is a compelling 
        reason, abi.encode should be preferred.
        """

        This is why in this PRNG generator we will always use abi.encode
     */
    function rotate() public returns (uint256) {
        // Allow overflow of the seed, what we want here is the possibility for
        // the seed to rotate indiscriminately over all the number in range without
        // ever throwing an error.
        // This give the possibility to call this function every time possible.
        // The seed presence gives also the possibility to call this function subsequently even in
        // the same transaction and receive 2 different outputs
        int256 previousSeed;
        unchecked {
            previousSeed = seed - 1;
            seed++;
        }

        return
            uint256(
                keccak256(
                    // The data encoded into the abi should give enough entropy for an average security but
                    // as solidity's source code is publicly accessible under certain conditions
                    // the value may be partially manipulated by evil actors
                    abi.encode(
                        seed,                                   // can be manipulated calling an arbitrary number of times this method
                        // keccak256(abi.encode(seed)),         // can be manipulated calling an arbitrary number of times this method
                        block.coinbase,                         // can be at least partially manipulated by miners (actual miner address)
                        block.difficulty,                       // defined by the network (cannot be manipulated)
                        block.gaslimit,                         // defined by the network (cannot be manipulated)
                        block.number,                           // can be manipulated by miners
                        block.timestamp,                        // can be at least partially manipulated by miners (+-15s allowed on eth for block acceptance)
                        // blockhash(block.number - 1),         // defined by the network (cannot be manipulated)
                        // blockhash(block.number - 2),         // defined by the network (cannot be manipulated)
                        block.basefee,                          // can be at least partially manipulated by miners
                        block.chainid,                          // defined by the network (cannot be manipulated)
                        gasleft(),                              // can be at least partially manipulated by users
                        // msg.data,                            // not allowed as strongly controlled by users, this can help forging a partially predictable hash
                        msg.sender,                             // can be at least partially manipulated by users (actual caller address)
                        msg.sig,                                // current function identifier (cannot be manipulated)
                        // msg.value,                           // not allowed as strongly controlled by users, this can help forging a partially predictable hash
                        previousSeed                            // can be manipulated calling an arbitrary number of times this method
                        // keccak256(abi.encode(previousSeed))  // can be manipulated calling an arbitrary number of times this method
                    )
                )
            );
    }
}


// File contracts/IPRNG.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;


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


// File contracts/StackingPanda.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;





contract StackingPanda is ERC721, Ownable, IPRNG, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

	struct StackingBonus {
        uint8 decimals;
        uint256 meldToMeld;
        uint256 toMeld;
    }

    struct Metadata {
        string name;
        string picUrl;
        StackingBonus bonus;
    }

    Metadata[] private metadata;

    address public masterchef;
    PRNG private prng;

    event NewPandaMinted(uint256 pandaId, string pandaName);

    // Init the NFT contract with the ownable abstact in order to let only the owner
    // mint new NFTs
    constructor() ERC721("Melodity Stacking Panda", "STACKP") Ownable() {
        masterchef = msg.sender;
        prng = PRNG(computePRNGAddress(masterchef));
    }

    /**
        Mint new NFTs, the maximum number of mintable NFT is 100.
        Only the owner of the contract can call this method.
        NFTs will be minted to the owner of the contract (alias, the creator); in order
        to let the Masterchef sell the NFT immediately after minting this contract *must*
        be deployed onchain by the Masterchef itself.

        @param _name Panda NFT name
        @param _picUrl The url where the picture is stored
        @param _stackingBonus As these NFTs are designed to give stacking bonuses this 
                value defines the reward bonuses
        @return uint256 Just minted nft id
     */
    function mint(
        string calldata _name,
        string calldata _picUrl,
        StackingBonus calldata _stackingBonus
    ) public nonReentrant onlyOwner returns (uint256) {
        prng.rotate();

        // Only 100 NFTs will be mintable
        require(_tokenIds.current() < 100, "All pandas minted");

        uint256 newItemId = _tokenIds.current();
        _tokenIds.increment();

        // incrementing the counter after taking its value makes possible the aligning
        // between the metadata array and the panda id, this let us simply push the metadata
        // to the end of the array instead of calculating where to place the data
        metadata.push(
            Metadata({name: _name, picUrl: _picUrl, bonus: _stackingBonus})
        );
        _mint(owner(), newItemId);

        emit NewPandaMinted(newItemId, _name);

        return newItemId;
    }

    /**
        Retrieve and return the metadata for the provided _nftId
        @param _nftId Identifier of the NFT whose data should be returned
        @return Metadata
     */
    function getMetadata(uint256 _nftId) public view returns (Metadata memory) {
        return metadata[_nftId];
    }
}


// File @openzeppelin/contracts/utils/introspection/ERC165Checker.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165Checker.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
    // As per the EIP-165 spec, no interface should ever match 0xffffffff
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @dev Returns true if `account` supports the {IERC165} interface,
     */
    function supportsERC165(address account) internal view returns (bool) {
        // Any contract that implements ERC165 must explicitly indicate support of
        // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    /**
     * @dev Returns true if `account` supports the interface defined by
     * `interfaceId`. Support for {IERC165} itself is queried automatically.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        // query support of both ERC165 as per the spec and support of _interfaceId
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    /**
     * @dev Returns a boolean array where each value corresponds to the
     * interfaces passed in and whether they're supported or not. This allows
     * you to batch check interfaces for a contract where your expectation
     * is that some interfaces may not be supported.
     *
     * See {IERC165-supportsInterface}.
     *
     * _Available since v3.4._
     */
    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        // an array of booleans corresponding to interfaceIds and whether they're supported or not
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        // query support of ERC165 itself
        if (supportsERC165(account)) {
            // query support of each interface in interfaceIds
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    /**
     * @dev Returns true if `account` supports all the interfaces defined in
     * `interfaceIds`. Support for {IERC165} itself is queried automatically.
     *
     * Batch-querying can lead to gas savings by skipping repeated checks for
     * {IERC165} support.
     *
     * See {IERC165-supportsInterface}.
     */
    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        // query support of ERC165 itself
        if (!supportsERC165(account)) {
            return false;
        }

        // query support of each interface in _interfaceIds
        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        // all interfaces supported
        return true;
    }

    /**
     * @notice Query if a contract implements an interface, does not check ERC165 support
     * @param account The address of the contract to query for support of an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return true if the contract at account indicates support of the interface with
     * identifier interfaceId, false otherwise
     * @dev Assumes that account contains a contract that supports ERC165, otherwise
     * the behavior of this method is undefined. This precondition can be checked
     * with {supportsERC165}.
     * Interface identification is specified in ERC-165.
     */
    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}


// File contracts/Marketplace/Auction.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;






contract Auction is ERC721Holder, IPRNG, ReentrancyGuard {
    PRNG public prng;

    address payable public beneficiary;
    uint256 public auctionEndTime;

    // Current state of the auction.
    address public highestBidder;
    uint256 public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint256) public pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool public ended;

    address public nftContract;
    uint256 public nftId;
    uint256 public minimumBid;

    address public royaltyReceiver;
    uint256 public royaltyPercent;

    event HighestBidIncreased(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event AuctionNotFullfilled(uint256 nftId, address nftContract, uint256 minimumBid);
    event RoyaltyPaid(address receiver, uint256 amount, uint256 royaltyPercentage);

    /**
        Create an auction with `biddingTime` seconds bidding time on behalf of the
        beneficiary address `beneficiaryAddress`.

        @param _biddingTime Number of seconds the auction will be valid
        @param _beneficiaryAddress The address where the highest big will be credited
        @param _nftId The unique identifier of the NFT that is being sold
        @param _nftContract The address of the contract of the NFT
        @param _minimumBid The minimum bid that must be placed in order for the auction to start.
                Bid lower than this amount are refused.
                If no bid is higher than this amount at the end of the auction the NFT will be sent
                to the beneficiary
        @param _royaltyReceiver The address of the royalty receiver for a given auction
        @param _royaltyPercentage The 18 decimals percentage of the highest bid that will be sent to 
                the royalty receiver
		@param _masterchef The address of the masterchef who deployed the prng
    */
    constructor(
        uint256 _biddingTime,
        address payable _beneficiaryAddress,
        uint256 _nftId,
        address _nftContract,
        uint256 _minimumBid,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
		address _masterchef
    ) {
        prng = PRNG(computePRNGAddress(_masterchef));
        prng.rotate();

        beneficiary = _beneficiaryAddress;
        auctionEndTime = block.timestamp + _biddingTime;
        nftContract = _nftContract;
        nftId = _nftId;
        minimumBid = _minimumBid;
        royaltyReceiver = _royaltyReceiver;
        royaltyPercent = _royaltyPercentage;
    }

    /** 
        Bid on the auction with the value sent together with this transaction.
        The value will only be refunded if the auction is not won.
    */
    function bid() public nonReentrant payable {
        prng.rotate();

        // check that the auction is still in its bidding period
        require(block.timestamp <= auctionEndTime, "Auction already ended");
        
        // check that the bid is higher or equal to the minimum bid to participate
        // in this auction
        require(msg.value >= minimumBid, "Bid not high enough to participate in this auction");

        // check that the current bid is higher than the previous
        require(msg.value > highestBid, "Higher or equal bid already present");

        if (highestBid != 0) {
            // save the previously highest bid in the pending return pot
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /**
        Withdraw a bids that were overbid.
    */
    function withdraw() public nonReentrant {
        prng.rotate();

        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            // send the previous bid back to the sender
            Address.sendValue(payable(msg.sender), amount);
        }
    }

    /** 
        End the auction and send the highest bid to the beneficiary.
        If defined split the bid with the royalty receiver
    */
    function endAuction() public nonReentrant {
        prng.rotate();

        // check that the auction is ended
        require(block.timestamp >= auctionEndTime, "Auction not ended yet");
        // check that the auction end call have not already been called
        require(!ended, "Auction already ended");

        // mark the auction as ended
        ended = true;

        if (highestBid == 0) {
            // send the NFT to the beneficiary if no bid has been accepted
            ERC721(nftContract).safeTransferFrom(address(this), beneficiary, nftId);
            emit AuctionNotFullfilled(nftId, nftContract, minimumBid);
        }
        else {
            // send the NFT to the bidder
            ERC721(nftContract).safeTransferFrom(address(this), highestBidder, nftId);

            // check if the royalty receiver and the payee are the same address
            // if they are make a transfer only, otherwhise split the bid based on
            // the royalty percentage and send the values

            if (beneficiary == royaltyReceiver) {
                // send the highest bid to the beneficiary
                Address.sendValue(beneficiary, highestBid);
            }
            else {
                // the royalty percentage has 18 decimals + 2 per percentage
                uint256 royalty = highestBid * royaltyPercent / 10 ** 20;
                uint256 beneficiaryEarning = highestBid - royalty;

                // send the royalty funds
                Address.sendValue(payable(royaltyReceiver), royalty);
                emit RoyaltyPaid(royaltyReceiver, royalty, royaltyPercent);

                // send the beneficiary earnings
                Address.sendValue(beneficiary, beneficiaryEarning);
            }

            emit AuctionEnded(highestBidder, highestBid);
        }
    }
}


// File contracts/Marketplace/BlindAuction.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;






contract BlindAuction is ERC721Holder, IPRNG, ReentrancyGuard {
    PRNG public prng;

    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    address public nftContract;
    uint256 public nftId;
    uint256 public minimumBid;

    address public royaltyReceiver;
    uint256 public royaltyPercent;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint256 public highestBid;

    // Allowed withdrawals of previous bids that were overbid
    mapping(address => uint256) private pendingReturns;

    event BidPlaced(address bidder);
    event AuctionEnded(address winner, uint256 highestBid);
    event AuctionNotFullfilled(uint256 nftId, address nftContract, uint256 minimumBid);
    event RoyaltyPaid(address receiver, uint256 amount, uint256 royaltyPercentage);

    // Modifiers are a convenient way to validate inputs to
    // functions. `onlyBefore` is applied to `bid` below:
    // The new function body is the modifier's body where
    // `_` is replaced by the old function body.
    modifier onlyBefore(uint256 time) {
        require(block.timestamp < time, "Method called too late");
        _;
    }
    modifier onlyAfter(uint256 time) {
        require(block.timestamp > time, "Method called too early");
        _;
    }

    constructor(
        uint256 _biddingTime,
        uint256 _revealTime,
        address payable _beneficiaryAddress,
        uint256 _nftId,
        address _nftContract,
        uint256 _minimumBid,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        address _masterchef
    ) {
        prng = PRNG(computePRNGAddress(_masterchef));
        prng.rotate();

        beneficiary = _beneficiaryAddress;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
        nftContract = _nftContract;
        nftId = _nftId;
        minimumBid = _minimumBid;
        royaltyReceiver = _royaltyReceiver;
        royaltyPercent = _royaltyPercentage;
    }

    /** 
		Place a blinded bid with 
		`blindedBid` = keccak256(abi.encode(value, fake, secret)).
    	The sent ether is only refunded if the bid is correctly
     	revealed in the revealing phase. 
		The bid is valid if the ether sent together with the bid 
		is at least "value" and "fake" is not true. 
		Setting "fake" to true and sending not the exact amount 
		are ways to hide the real bid but still make the required 
		deposit. 
		The same address can place multiple bids.
	*/
    function bid(bytes32 blindedBid) public payable nonReentrant onlyBefore(biddingEnd) {
        prng.rotate();

        bids[msg.sender].push(
            Bid({blindedBid: blindedBid, deposit: msg.value})
        );

        emit BidPlaced(msg.sender);
    }

    /** 
		Reveal blinded bids. The user will get a refund for all
    	correctly blinded invalid bids and for all bids except for
    	the totally highest.
	*/
    function reveal(
        uint256[] calldata values,
        bool[] calldata fakes,
        bytes32[] calldata secrets
    ) public nonReentrant onlyAfter(biddingEnd) onlyBefore(revealEnd) {
        prng.rotate();

		// check that the list of provided bids has the same length of
		// the list saved in the contract
        uint256 length = bids[msg.sender].length;
		require(values.length == length, "You're not revealing all your bids");
		require(fakes.length == length, "You're not revealing all your bids");
		require(secrets.length == length, "You're not revealing all your bids");

        uint256 refund;
		// loop through each bid
        for (uint256 i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];

            (uint256 value, bool fake, bytes32 secret) = (
                values[i],
                fakes[i],
                secrets[i]
            );

			// if the bid do not match the original value it is skipped
            if (
                bidToCheck.blindedBid !=
                keccak256(abi.encode(value, fake, secret))
            ) {
                continue;
            }

            refund += bidToCheck.deposit;
			// check that a bid is not fake, if it is not than check that
			// the deposit is >= to the value reported in the bid
            if (!fake && bidToCheck.deposit >= value) {
				// try to place a public bid
                if (placeBid(msg.sender, value)) {
                    refund -= value;
                }
            }

            // Make it impossible for the sender to re-claim
            // the same deposit.
            bidToCheck.blindedBid = bytes32(0);
        }

		// refund fake or invalid bids
        Address.sendValue(payable(msg.sender), refund);
    }

    /** 
		Withdraw a bid that was overbid.
	*/
    function withdraw() public nonReentrant {
        prng.rotate();

        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            // send the previous bid back to the sender
            Address.sendValue(payable(msg.sender), amount);
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function endAuction() public nonReentrant onlyAfter(revealEnd) {
        prng.rotate();

        // check that the auction end call have not already been called
        require(!ended, "Auction already ended");

        // mark the auction as ended
        ended = true;

        if (highestBid == 0) {
            // send the NFT to the beneficiary if no bid has been accepted
            ERC721(nftContract).transferFrom(address(this), beneficiary, nftId);
            emit AuctionNotFullfilled(nftId, nftContract, minimumBid);
        }
        else {
            // send the NFT to the bidder
            ERC721(nftContract).safeTransferFrom(address(this), highestBidder, nftId);

            // check if the royalty receiver and the payee are the same address
            // if they are make a transfer only, otherwhise split the bid based on
            // the royalty percentage and send the values
            if (beneficiary == royaltyReceiver) {
                // send the highest bid to the beneficiary
                Address.sendValue(beneficiary, highestBid);
            }
            else {
                // the royalty percentage has 18 decimals + 2 percetage positions
                uint256 royalty = highestBid * royaltyPercent / 10 ** 20;
                uint256 beneficiaryEarning = highestBid - royalty;

                // send the royalty funds
                Address.sendValue(payable(royaltyReceiver), royalty);
                emit RoyaltyPaid(royaltyReceiver, royalty, royaltyPercent);

                // send the beneficiary earnings
                Address.sendValue(beneficiary, beneficiaryEarning);
            }

            emit AuctionEnded(highestBidder, highestBid);
        }
    }

    /**
		Place a public bid.
		This method is called internally by the reveal method.

		@return success True if the bid is higher than the current highest
			if true is returned the highet bidder is updated
	 */
    function placeBid(address bidder, uint256 value)
        private
        returns (bool success)
    {
		// refuse revealed bids that are lower than the current
		// highest bid or that are lower than the minimum bid
        if (value <= highestBid || value < minimumBid) {
            return false;
        }

        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = value;
        highestBidder = bidder;
        return true;
    }
}


// File contracts/Marketplace/Marketplace.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;








contract Marketplace is IPRNG, ReentrancyGuard {
    PRNG public prng;
    address private _masterchef;

    Auction[] public auctions;
    BlindAuction[] public blindAuctions;

    struct Royalty {
        // number of decimal position to include in the royalty percent
        uint8 decimals;
        // royalty percent from 0 to 100% with `decimals` decimal position
        uint256 royaltyPercent;
        // address that will receive the royalties for future sales via this
        // smart contract. Other smart contracts functionalities cannot be
        // controlled in any way
        address royaltyReceiver;
        // address of the one who can edit all this royalty settings
        address royaltyInitializer;
    }

    /**
        This mapping is a workaround for a double map with 2 indexes.
        index: keccak256(
            abi.encode(
                nft smart contract address,
                nft identifier
            )
        )
        map: Royalty
     */
    mapping(bytes32 => Royalty) public royalties;

    /*
     *     bytes4(keccak256("balanceOf(address)")) == 0x70a08231
     *     bytes4(keccak256("ownerOf(uint256)")) == 0x6352211e
     *     bytes4(keccak256("approve(address,uint256)")) == 0x095ea7b3
     *     bytes4(keccak256("getApproved(uint256)")) == 0x081812fc
     *     bytes4(keccak256("setApprovalForAll(address,bool)")) == 0xa22cb465
     *     bytes4(keccak256("isApprovedForAll(address,address)")) == 0xe985e9c5
     *     bytes4(keccak256("transferFrom(address,address,uint256)")) == 0x23b872dd
     *     bytes4(keccak256("safeTransferFrom(address,address,uint256)")) == 0x42842e0e
     *     bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)")) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*
     *     bytes4(keccak256("name()")) == 0x06fdde03
     *     bytes4(keccak256("symbol()")) == 0x95d89b41
     *     bytes4(keccak256("tokenURI(uint256)")) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    event AuctionCreated(address auction, uint256 nftId, address nftContract);
    event BlindAuctionCreated(
        address auction,
        uint256 nftId,
        address nftContract
    );
    event RoyaltyUpdated(
        uint256 nftId,
        address nftContract,
        uint256 royaltyPercent,
        address royaltyReceiver,
        address royaltyInitializer
    );

    modifier onlyERC721(address _contract) {
        prng.rotate();

        require(
            // check the SC doesn't supports the ERC721 openzeppelin interface
            ERC165Checker.supportsInterface(_contract, _INTERFACE_ID_ERC721) &&
                // check the SC doesn't supports the ERC721-Metadata openzeppelin interface
                ERC165Checker.supportsInterface(
                    _contract,
                    _INTERFACE_ID_ERC721_METADATA
                ),
            "The provided address does not seem to implement the ERC721 NFT standard"
        );

        _;
    }

    constructor() {
        _masterchef = msg.sender;
        prng = PRNG(computePRNGAddress(msg.sender));
        prng.rotate();
    }

    /**
        Create a public auction. The auctioner *must* own the NFT to sell.
        Once the auction ends anyone can trigger the release of the funds raised.
        All the participant can also release their bids at anytime if they are not the
        higher bidder.
        This contract is not responsible for handling the real auction but only for its creation.

        NOTE: Before actually starting the creation of the auction the user needs
        to allow the transfer of the nft.

        @param _nftId The unique identifier of the NFT that is being sold
        @param _nftContract The address of the contract of the NFT
        @param _payee The address where the highest big will be credited
        @param _auctionDuration Number of seconds the auction will be valid
        @param _minimumPrice The minimum bid that must be placed in order for the auction to start.
                Bid lower than this amount are refused.
                If no bid is higher than this amount at the end of the auction the NFT will be sent
                to the beneficiary
        @param _royaltyReceiver The address of the royalty receiver for a given auction
        @param _royaltyPercentage The 18 decimals percentage of the highest bid that will be sent to 
                the royalty receiver
		@param _blind Whether the auction to be created is a blind auction or a simple one
     */
    function createAuction(
        uint256 _nftId,
        address _nftContract,
        address _payee,
        uint256 _auctionDuration,
        uint256 _minimumPrice,
        address _royaltyReceiver,
        uint256 _royaltyPercentage,
        bool _blind
    ) private returns (address) {
        prng.rotate();

        // do not run any check on the contract as the checks are already performed by the
        // parent call

        // load the instance of the nft contract into the ERC721 interface in order
        // to expose all its methods
        ERC721 nftContractInstance = ERC721(_nftContract);

        address _auctionAddress;

        if (!_blind) {
            // create a new auction for the user
            Auction auction = new Auction(
                _auctionDuration,
                payable(_payee),
                _nftId,
                _nftContract,
                _minimumPrice,
                _royaltyReceiver,
                _royaltyPercentage,
                _masterchef
            );
            auctions.push(auction);
            _auctionAddress = address(auction);

            emit AuctionCreated(_auctionAddress, _nftId, _nftContract);
        } else {
            // create a new blind auction for the user
            BlindAuction blindAuction = new BlindAuction(
                _auctionDuration,
                1 days,
                payable(_payee),
                _nftId,
                _nftContract,
                _minimumPrice,
                _royaltyReceiver,
                _royaltyPercentage,
                _masterchef
            );
            blindAuctions.push(blindAuction);
            _auctionAddress = address(blindAuction);

            emit BlindAuctionCreated(_auctionAddress, _nftId, _nftContract);
        }

        // move the NFT from the owner to the auction contract
        nftContractInstance.safeTransferFrom(
            msg.sender,
            _auctionAddress,
            _nftId
        );

        return _auctionAddress;
    }

    /**
		Initialize a new royalty or return the already initialized for a
		(contract, nft id) pair

		@param _nftId The unique identifier of the NFT that is being sold
        @param _nftContract The address of the contract of the NFT
		@param _royaltyPercent The 18 decimals percentage of the highest bid that will be sent to 
                the royalty receiver
        @param _royaltyReceiver The address of the royalty receiver for a given auction
        @param _royaltyInitializer The address that will be allowed to edit the royalties, if the
                null address is provided sender address will be used
     */
    function initializeRoyalty(
        uint256 _nftId,
        address _nftContract,
        uint256 _royaltyPercent,
        address _royaltyReceiver,
        address _royaltyInitializer
    ) private returns (Royalty memory) {
        prng.rotate();

        bytes32 royaltyIdentifier = keccak256(abi.encode(_nftContract, _nftId));

        // check if the royalty is already defined, in case it is this is not
        // the call to edit it, the user *must* use the correct call to edit it
        Royalty memory royalty = royalties[royaltyIdentifier];

        // if the royalty initializer is the null address then the royalty is not
        // yet initialized and can be initialized now
        if (royalty.royaltyInitializer == address(0)) {
            // Check that _royaltyPercent is less or equal to 50% of the sold amount
            require(
                _royaltyPercent <= 50 ether,
                "Royalty percentage too high, max value is 50%"
            );

            // if the royalty initializer is set to the null address automatically
            // use the caller address
            if (_royaltyInitializer == address(0)) {
                _royaltyInitializer = msg.sender;
            }

            royalties[royaltyIdentifier] = Royalty({
                decimals: 18,
                royaltyPercent: _royaltyPercent, // the provided value *MUST* be padded to 18 decimal positions
                royaltyReceiver: _royaltyReceiver,
                royaltyInitializer: _royaltyInitializer
            });

            emit RoyaltyUpdated(
                _nftId,
                _nftContract,
                _royaltyPercent,
                _royaltyReceiver,
                _royaltyInitializer
            );

            return royalties[royaltyIdentifier];
        }

        return royalty;
    }

    /**
        Create a public auction and if not initialized yet, init the royalty for the
        (smart contract address, nft identifier) pair

        NOTE: This method cannot be used to edit royalties values
        WARNING: Only ERC721 compliant NFTs can be sold, other standards are not supported

        @param _nftId The unique identifier of the NFT that is being sold
        @param _nftContract The address of the contract of the NFT
        @param _payee The address where the highest big will be credited
        @param _auctionDuration Number of seconds the auction will be valid
        @param _minimumPrice The minimum bid that must be placed in order for the auction to start.
                Bid lower than this amount are refused.
                If no bid is higher than this amount at the end of the auction the NFT will be sent
                to the beneficiary
        @param _royaltyPercent The 18 decimals percentage of the highest bid that will be sent to 
                the royalty receiver
        @param _royaltyReceiver The address of the royalty receiver for a given auction
        @param _royaltyInitializer The address that will be allowed to edit the royalties, if the
                null address is provided sender address will be used
     */
    function createAuctionWithRoyalties(
        uint256 _nftId,
        address _nftContract,
        address _payee,
        uint256 _auctionDuration,
        uint256 _minimumPrice,
        uint256 _royaltyPercent,
        address _royaltyReceiver,
        address _royaltyInitializer
    ) public nonReentrant onlyERC721(_nftContract) returns (address) {
        // load the instance of the nft contract into the ERC721 interface in order
        // to expose all its methods
        ERC721 nftContractInstance = ERC721(_nftContract);

        // check that the marketplace is allowed to transfer the provided nft
        // for the user
        // ALERT: checking the approval does not check that the user actually owns the nft
        // as parameters can per forged to pass this check without the caller to actually
        // own the it. This won"t be a problem in a standard context but as we"re setting
        // up the royalty base here a check must be done in order to check if it is should be
        // set by the caller or not
        require(
            nftContractInstance.getApproved(_nftId) == address(this),
            "Trasfer not allowed for Marketplace operator"
        );

        // check if the caller is the owner of the nft in case it is then proceed with further setup
        require(
            nftContractInstance.ownerOf(_nftId) == msg.sender,
            "Not owning the provided NFT"
        );

        Royalty memory royalty = initializeRoyalty(
            _nftId,
            _nftContract,
            _royaltyPercent,
            _royaltyReceiver,
            _royaltyInitializer
        );

        return
            createAuction(
                _nftId,
                _nftContract,
                _payee,
                _auctionDuration,
                _minimumPrice,
                royalty.royaltyReceiver,
                royalty.royaltyPercent,
                false
            );
    }

    /**
        This call let the royalty initializer of a (smart contract, nft) pair
        edit the royalty settings.

        NOTE: The maximum royalty that can be taken is 50%
        WARNING: Only ERC721 compliant NFTs can be sold, other standards are not supported

		@param _nftId The unique identifier of the NFT that is being sold
		@param _nftContract The address of the contract of the NFT
		@param _royaltyPercent The 18 decimals percentage of the highest bid that will be sent to 
                the royalty receiver
		@param _royaltyReceiver The address of the royalty receiver for a given auction
		@param _royaltyInitializer The address that will be allowed to edit the royalties, if the
                null address is provided sender address will be used
     */
    function updateRoyalty(
        uint256 _nftId,
        address _nftContract,
        uint256 _royaltyPercent,
        address _royaltyReceiver,
        address _royaltyInitializer
    ) public nonReentrant onlyERC721(_nftContract) returns (Royalty memory) {
        bytes32 royaltyIdentifier = keccak256(abi.encode(_nftContract, _nftId));

        Royalty memory royalty = royalties[royaltyIdentifier];

        require(
            msg.sender == royalty.royaltyInitializer,
            "You're not the owner of the royalty"
        );

        // Check that _royaltyPercent is less or equal to 50% of the sold amount
        require(
            _royaltyPercent <= 50 ether,
            "Royalty percentage too high, max value is 50%"
        );

        // if the royalty initializer is set to the null address automatically
        // use the caller address
        if (_royaltyInitializer == address(0)) {
            _royaltyInitializer = msg.sender;
        }

        royalties[royaltyIdentifier] = Royalty({
            decimals: 18,
            royaltyPercent: _royaltyPercent, // the provided value *MUST* be padded to 18 decimal positions
            royaltyReceiver: _royaltyReceiver,
            royaltyInitializer: _royaltyInitializer
        });

        emit RoyaltyUpdated(
            _nftId,
            _nftContract,
            _royaltyPercent,
            _royaltyReceiver,
            _royaltyInitializer
        );

        return royalties[royaltyIdentifier];
    }

    function createBlindAuction(
        uint256 _nftId,
        address _nftContract,
        address _payee,
        uint256 _auctionDuration,
        uint256 _minimumPrice,
        uint256 _royaltyPercent,
        address _royaltyReceiver,
        address _royaltyInitializer
    ) public nonReentrant onlyERC721(_nftContract) returns (address) {
        // load the instance of the nft contract into the ERC721 interface in order
        // to expose all its methods
        ERC721 nftContractInstance = ERC721(_nftContract);

        // check that the marketplace is allowed to transfer the provided nft
        // for the user
        // ALERT: checking the approval does not check that the user actually owns the nft
        // as parameters can per forged to pass this check without the caller to actually
        // own the it. This won"t be a problem in a standard context but as we"re setting
        // up the royalty base here a check must be done in order to check if it is should be
        // set by the caller or not
        require(
            nftContractInstance.getApproved(_nftId) == address(this),
            "Trasfer not allowed for Marketplace operator"
        );

        // check if the caller is the owner of the nft in case it is then proceed with further setup
        require(
            nftContractInstance.ownerOf(_nftId) == msg.sender,
            "Not owning the provided NFT"
        );
        Royalty memory royalty = initializeRoyalty(
            _nftId,
            _nftContract,
            _royaltyPercent,
            _royaltyReceiver,
            _royaltyInitializer
        );

        return
            createAuction(
                _nftId,
                _nftContract,
                _payee,
                _auctionDuration,
                _minimumPrice,
                royalty.royaltyReceiver,
                royalty.royaltyPercent,
                true
            );
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts/utils/cryptography/ECDSA.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


// File @openzeppelin/contracts/utils/cryptography/draft-EIP712.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-ERC20Permit.sol)

pragma solidity ^0.8.0;





/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {}

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}


// File @openzeppelin/contracts/utils/math/Math.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}


// File @openzeppelin/contracts/utils/math/SafeCast.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Votes.sol)

pragma solidity ^0.8.0;




/**
 * @dev Extension of ERC20 to support Compound-like voting and delegation. This version is more generic than Compound's,
 * and supports token supply up to 2^224^ - 1, while COMP is limited to 2^96^ - 1.
 *
 * NOTE: If exact COMP compatibility is required, use the {ERC20VotesComp} variant of this module.
 *
 * This extension keeps a history (checkpoints) of each account's vote power. Vote power can be delegated either
 * by calling the {delegate} function directly, or by providing a signature to be used with {delegateBySig}. Voting
 * power can be queried through the public accessors {getVotes} and {getPastVotes}.
 *
 * By default, token balance does not account for voting power. This makes transfers cheaper. The downside is that it
 * requires users to delegate to themselves in order to activate checkpoints and have their voting power tracked.
 * Enabling self-delegation can easily be done by overriding the {delegates} function. Keep in mind however that this
 * will significantly increase the base gas cost of transfers.
 *
 * _Available since v4.2._
 */
abstract contract ERC20Votes is ERC20Permit {
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    bytes32 private constant _DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => address) private _delegates;
    mapping(address => Checkpoint[]) private _checkpoints;
    Checkpoint[] private _totalSupplyCheckpoints;

    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to an account's voting power.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Get the `pos`-th checkpoint for `account`.
     */
    function checkpoints(address account, uint32 pos) public view virtual returns (Checkpoint memory) {
        return _checkpoints[account][pos];
    }

    /**
     * @dev Get number of checkpoints for `account`.
     */
    function numCheckpoints(address account) public view virtual returns (uint32) {
        return SafeCast.toUint32(_checkpoints[account].length);
    }

    /**
     * @dev Get the address `account` is currently delegating to.
     */
    function delegates(address account) public view virtual returns (address) {
        return _delegates[account];
    }

    /**
     * @dev Gets the current votes balance for `account`
     */
    function getVotes(address account) public view returns (uint256) {
        uint256 pos = _checkpoints[account].length;
        return pos == 0 ? 0 : _checkpoints[account][pos - 1].votes;
    }

    /**
     * @dev Retrieve the number of votes for `account` at the end of `blockNumber`.
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastVotes(address account, uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_checkpoints[account], blockNumber);
    }

    /**
     * @dev Retrieve the `totalSupply` at the end of `blockNumber`. Note, this value is the sum of all balances.
     * It is but NOT the sum of all the delegated votes!
     *
     * Requirements:
     *
     * - `blockNumber` must have been already mined
     */
    function getPastTotalSupply(uint256 blockNumber) public view returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(_totalSupplyCheckpoints, blockNumber);
    }

    /**
     * @dev Lookup a value in a list of (sorted) checkpoints.
     */
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber) private view returns (uint256) {
        // We run a binary search to look for the earliest checkpoint taken after `blockNumber`.
        //
        // During the loop, the index of the wanted checkpoint remains in the range [low-1, high).
        // With each iteration, either `low` or `high` is moved towards the middle of the range to maintain the invariant.
        // - If the middle checkpoint is after `blockNumber`, we look in [low, mid)
        // - If the middle checkpoint is before or equal to `blockNumber`, we look in [mid+1, high)
        // Once we reach a single value (when low == high), we've found the right checkpoint at the index high-1, if not
        // out of bounds (in which case we're looking too far in the past and the result is 0).
        // Note that if the latest checkpoint available is exactly for `blockNumber`, we end up with an index that is
        // past the end of the array, so we technically don't find a checkpoint after `blockNumber`, but it works out
        // the same.
        uint256 high = ckpts.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (ckpts[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : ckpts[high - 1].votes;
    }

    /**
     * @dev Delegate votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) public virtual {
        _delegate(_msgSender(), delegatee);
    }

    /**
     * @dev Delegates votes from signer to `delegatee`
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(block.timestamp <= expiry, "ERC20Votes: signature expired");
        address signer = ECDSA.recover(
            _hashTypedDataV4(keccak256(abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry))),
            v,
            r,
            s
        );
        require(nonce == _useNonce(signer), "ERC20Votes: invalid nonce");
        _delegate(signer, delegatee);
    }

    /**
     * @dev Maximum token supply. Defaults to `type(uint224).max` (2^224^ - 1).
     */
    function _maxSupply() internal view virtual returns (uint224) {
        return type(uint224).max;
    }

    /**
     * @dev Snapshots the totalSupply after it has been increased.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        require(totalSupply() <= _maxSupply(), "ERC20Votes: total supply risks overflowing votes");

        _writeCheckpoint(_totalSupplyCheckpoints, _add, amount);
    }

    /**
     * @dev Snapshots the totalSupply after it has been decreased.
     */
    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);

        _writeCheckpoint(_totalSupplyCheckpoints, _subtract, amount);
    }

    /**
     * @dev Move voting power when tokens are transferred.
     *
     * Emits a {DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);

        _moveVotingPower(delegates(from), delegates(to), amount);
    }

    /**
     * @dev Change delegation for `delegator` to `delegatee`.
     *
     * Emits events {DelegateChanged} and {DelegateVotesChanged}.
     */
    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates(delegator);
        uint256 delegatorBalance = balanceOf(delegator);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveVotingPower(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveVotingPower(
        address src,
        address dst,
        uint256 amount
    ) private {
        if (src != dst && amount > 0) {
            if (src != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[src], _subtract, amount);
                emit DelegateVotesChanged(src, oldWeight, newWeight);
            }

            if (dst != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[dst], _add, amount);
                emit DelegateVotesChanged(dst, oldWeight, newWeight);
            }
        }
    }

    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        oldWeight = pos == 0 ? 0 : ckpts[pos - 1].votes;
        newWeight = op(oldWeight, delta);

        if (pos > 0 && ckpts[pos - 1].fromBlock == block.number) {
            ckpts[pos - 1].votes = SafeCast.toUint224(newWeight);
        } else {
            ckpts.push(Checkpoint({fromBlock: SafeCast.toUint32(block.number), votes: SafeCast.toUint224(newWeight)}));
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Wrapper.sol)

pragma solidity ^0.8.0;


/**
 * @dev Extension of the ERC20 token contract to support token wrapping.
 *
 * Users can deposit and withdraw "underlying tokens" and receive a matching number of "wrapped tokens". This is useful
 * in conjunction with other modules. For example, combining this wrapping mechanism with {ERC20Votes} will allow the
 * wrapping of an existing "basic" ERC20 into a governance token.
 *
 * _Available since v4.2._
 */
abstract contract ERC20Wrapper is ERC20 {
    IERC20 public immutable underlying;

    constructor(IERC20 underlyingToken) {
        underlying = underlyingToken;
    }

    /**
     * @dev Allow a user to deposit underlying tokens and mint the corresponding number of wrapped tokens.
     */
    function depositFor(address account, uint256 amount) public virtual returns (bool) {
        SafeERC20.safeTransferFrom(underlying, _msgSender(), address(this), amount);
        _mint(account, amount);
        return true;
    }

    /**
     * @dev Allow a user to burn a number of wrapped tokens and withdraw the corresponding number of underlying tokens.
     */
    function withdrawTo(address account, uint256 amount) public virtual returns (bool) {
        _burn(_msgSender(), amount);
        SafeERC20.safeTransfer(underlying, account, amount);
        return true;
    }

    /**
     * @dev Mint wrapped token to cover any underlyingTokens that would have been transfered by mistake. Internal
     * function that can be exposed with access control if desired.
     */
    function _recover(address account) internal virtual returns (uint256) {
        uint256 value = underlying.balanceOf(address(this)) - totalSupply();
        _mint(account, value);
        return value;
    }
}


// File contracts/DAO/MelodityGovernance.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;





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


// File @openzeppelin/contracts/access/IAccessControl.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}


// File @openzeppelin/contracts/access/AccessControl.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/AccessControl.sol)

pragma solidity ^0.8.0;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// File @openzeppelin/contracts/governance/TimelockController.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/TimelockController.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which acts as a timelocked controller. When set as the
 * owner of an `Ownable` smart contract, it enforces a timelock on all
 * `onlyOwner` maintenance operations. This gives time for users of the
 * controlled contract to exit before a potentially dangerous maintenance
 * operation is applied.
 *
 * By default, this contract is self administered, meaning administration tasks
 * have to go through the timelock process. The proposer (resp executor) role
 * is in charge of proposing (resp executing) operations. A common use case is
 * to position this {TimelockController} as the owner of a smart contract, with
 * a multisig or a DAO as the sole proposer.
 *
 * _Available since v3.3._
 */
contract TimelockController is AccessControl {
    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    uint256 internal constant _DONE_TIMESTAMP = uint256(1);

    mapping(bytes32 => uint256) private _timestamps;
    uint256 private _minDelay;

    /**
     * @dev Emitted when a call is scheduled as part of operation `id`.
     */
    event CallScheduled(
        bytes32 indexed id,
        uint256 indexed index,
        address target,
        uint256 value,
        bytes data,
        bytes32 predecessor,
        uint256 delay
    );

    /**
     * @dev Emitted when a call is performed as part of operation `id`.
     */
    event CallExecuted(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data);

    /**
     * @dev Emitted when operation `id` is cancelled.
     */
    event Cancelled(bytes32 indexed id);

    /**
     * @dev Emitted when the minimum delay for future operations is modified.
     */
    event MinDelayChange(uint256 oldDuration, uint256 newDuration);

    /**
     * @dev Initializes the contract with a given `minDelay`.
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors
    ) {
        _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE);
        _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE);

        // deployer + self administration
        _setupRole(TIMELOCK_ADMIN_ROLE, _msgSender());
        _setupRole(TIMELOCK_ADMIN_ROLE, address(this));

        // register proposers
        for (uint256 i = 0; i < proposers.length; ++i) {
            _setupRole(PROPOSER_ROLE, proposers[i]);
        }

        // register executors
        for (uint256 i = 0; i < executors.length; ++i) {
            _setupRole(EXECUTOR_ROLE, executors[i]);
        }

        _minDelay = minDelay;
        emit MinDelayChange(0, minDelay);
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRoleOrOpenRole(bytes32 role) {
        if (!hasRole(role, address(0))) {
            _checkRole(role, _msgSender());
        }
        _;
    }

    /**
     * @dev Contract might receive/hold ETH as part of the maintenance process.
     */
    receive() external payable {}

    /**
     * @dev Returns whether an id correspond to a registered operation. This
     * includes both Pending, Ready and Done operations.
     */
    function isOperation(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > 0;
    }

    /**
     * @dev Returns whether an operation is pending or not.
     */
    function isOperationPending(bytes32 id) public view virtual returns (bool pending) {
        return getTimestamp(id) > _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns whether an operation is ready or not.
     */
    function isOperationReady(bytes32 id) public view virtual returns (bool ready) {
        uint256 timestamp = getTimestamp(id);
        return timestamp > _DONE_TIMESTAMP && timestamp <= block.timestamp;
    }

    /**
     * @dev Returns whether an operation is done or not.
     */
    function isOperationDone(bytes32 id) public view virtual returns (bool done) {
        return getTimestamp(id) == _DONE_TIMESTAMP;
    }

    /**
     * @dev Returns the timestamp at with an operation becomes ready (0 for
     * unset operations, 1 for done operations).
     */
    function getTimestamp(bytes32 id) public view virtual returns (uint256 timestamp) {
        return _timestamps[id];
    }

    /**
     * @dev Returns the minimum delay for an operation to become valid.
     *
     * This value can be changed by executing an operation that calls `updateDelay`.
     */
    function getMinDelay() public view virtual returns (uint256 duration) {
        return _minDelay;
    }

    /**
     * @dev Returns the identifier of an operation containing a single
     * transaction.
     */
    function hashOperation(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(target, value, data, predecessor, salt));
    }

    /**
     * @dev Returns the identifier of an operation containing a batch of
     * transactions.
     */
    function hashOperationBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public pure virtual returns (bytes32 hash) {
        return keccak256(abi.encode(targets, values, datas, predecessor, salt));
    }

    /**
     * @dev Schedule an operation containing a single transaction.
     *
     * Emits a {CallScheduled} event.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _schedule(id, delay);
        emit CallScheduled(id, 0, target, value, data, predecessor, delay);
    }

    /**
     * @dev Schedule an operation containing a batch of transactions.
     *
     * Emits one {CallScheduled} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function scheduleBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) public virtual onlyRole(PROPOSER_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _schedule(id, delay);
        for (uint256 i = 0; i < targets.length; ++i) {
            emit CallScheduled(id, i, targets[i], values[i], datas[i], predecessor, delay);
        }
    }

    /**
     * @dev Schedule an operation that is to becomes valid after a given delay.
     */
    function _schedule(bytes32 id, uint256 delay) private {
        require(!isOperation(id), "TimelockController: operation already scheduled");
        require(delay >= getMinDelay(), "TimelockController: insufficient delay");
        _timestamps[id] = block.timestamp + delay;
    }

    /**
     * @dev Cancel an operation.
     *
     * Requirements:
     *
     * - the caller must have the 'proposer' role.
     */
    function cancel(bytes32 id) public virtual onlyRole(PROPOSER_ROLE) {
        require(isOperationPending(id), "TimelockController: operation cannot be cancelled");
        delete _timestamps[id];

        emit Cancelled(id);
    }

    /**
     * @dev Execute an (ready) operation containing a single transaction.
     *
     * Emits a {CallExecuted} event.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        bytes32 id = hashOperation(target, value, data, predecessor, salt);
        _beforeCall(id, predecessor);
        _call(id, 0, target, value, data);
        _afterCall(id);
    }

    /**
     * @dev Execute an (ready) operation containing a batch of transactions.
     *
     * Emits one {CallExecuted} event per transaction in the batch.
     *
     * Requirements:
     *
     * - the caller must have the 'executor' role.
     */
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas,
        bytes32 predecessor,
        bytes32 salt
    ) public payable virtual onlyRoleOrOpenRole(EXECUTOR_ROLE) {
        require(targets.length == values.length, "TimelockController: length mismatch");
        require(targets.length == datas.length, "TimelockController: length mismatch");

        bytes32 id = hashOperationBatch(targets, values, datas, predecessor, salt);
        _beforeCall(id, predecessor);
        for (uint256 i = 0; i < targets.length; ++i) {
            _call(id, i, targets[i], values[i], datas[i]);
        }
        _afterCall(id);
    }

    /**
     * @dev Checks before execution of an operation's calls.
     */
    function _beforeCall(bytes32 id, bytes32 predecessor) private view {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        require(predecessor == bytes32(0) || isOperationDone(predecessor), "TimelockController: missing dependency");
    }

    /**
     * @dev Checks after execution of an operation's calls.
     */
    function _afterCall(bytes32 id) private {
        require(isOperationReady(id), "TimelockController: operation is not ready");
        _timestamps[id] = _DONE_TIMESTAMP;
    }

    /**
     * @dev Execute an operation's call.
     *
     * Emits a {CallExecuted} event.
     */
    function _call(
        bytes32 id,
        uint256 index,
        address target,
        uint256 value,
        bytes calldata data
    ) private {
        (bool success, ) = target.call{value: value}(data);
        require(success, "TimelockController: underlying transaction reverted");

        emit CallExecuted(id, index, target, value, data);
    }

    /**
     * @dev Changes the minimum timelock duration for future operations.
     *
     * Emits a {MinDelayChange} event.
     *
     * Requirements:
     *
     * - the caller must be the timelock itself. This can only be achieved by scheduling and later executing
     * an operation where the timelock is the target and the data is the ABI-encoded call to this function.
     */
    function updateDelay(uint256 newDelay) external virtual {
        require(msg.sender == address(this), "TimelockController: caller must be timelock");
        emit MinDelayChange(_minDelay, newDelay);
        _minDelay = newDelay;
    }
}


// File contracts/DAO/MelodityDAOTimelock.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract MelodityDAOTimelock is TimelockController {
	/**
		initialize with:
		MelodityDAOTimelock([], [address(0)])
	 */
	constructor(address[] memory _proposers, address[] memory _executors) 
	TimelockController(
		84 hours, 			// 3.5 days
		_proposers, 		// proposers
		_executors			// everyone can trigger the execution
	 ) {}
}


// File @openzeppelin/contracts/utils/Timers.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Timers.sol)

pragma solidity ^0.8.0;

/**
 * @dev Tooling for timepoints, timers and delays
 */
library Timers {
    struct Timestamp {
        uint64 _deadline;
    }

    function getDeadline(Timestamp memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(Timestamp storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(Timestamp storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(Timestamp memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(Timestamp memory timer) internal view returns (bool) {
        return timer._deadline > block.timestamp;
    }

    function isExpired(Timestamp memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.timestamp;
    }

    struct BlockNumber {
        uint64 _deadline;
    }

    function getDeadline(BlockNumber memory timer) internal pure returns (uint64) {
        return timer._deadline;
    }

    function setDeadline(BlockNumber storage timer, uint64 timestamp) internal {
        timer._deadline = timestamp;
    }

    function reset(BlockNumber storage timer) internal {
        timer._deadline = 0;
    }

    function isUnset(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline == 0;
    }

    function isStarted(BlockNumber memory timer) internal pure returns (bool) {
        return timer._deadline > 0;
    }

    function isPending(BlockNumber memory timer) internal view returns (bool) {
        return timer._deadline > block.number;
    }

    function isExpired(BlockNumber memory timer) internal view returns (bool) {
        return isStarted(timer) && timer._deadline <= block.number;
    }
}


// File @openzeppelin/contracts/governance/IGovernor.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/IGovernor.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the {Governor} core.
 *
 * _Available since v4.3._
 */
abstract contract IGovernor is IERC165 {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    /**
     * @dev Emitted when a proposal is created.
     */
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    /**
     * @dev Emitted when a proposal is canceled.
     */
    event ProposalCanceled(uint256 proposalId);

    /**
     * @dev Emitted when a proposal is executed.
     */
    event ProposalExecuted(uint256 proposalId);

    /**
     * @dev Emitted when a vote is cast.
     *
     * Note: `support` values should be seen as buckets. There interpretation depends on the voting module used.
     */
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    /**
     * @notice module:core
     * @dev Name of the governor instance (used in building the ERC712 domain separator).
     */
    function name() public view virtual returns (string memory);

    /**
     * @notice module:core
     * @dev Version of the governor instance (used in building the ERC712 domain separator). Default: "1"
     */
    function version() public view virtual returns (string memory);

    /**
     * @notice module:voting
     * @dev A description of the possible `support` values for {castVote} and the way these votes are counted, meant to
     * be consumed by UIs to show correct vote options and interpret the results. The string is a URL-encoded sequence of
     * key-value pairs that each describe one aspect, for example `support=bravo&quorum=for,abstain`.
     *
     * There are 2 standard keys: `support` and `quorum`.
     *
     * - `support=bravo` refers to the vote options 0 = Against, 1 = For, 2 = Abstain, as in `GovernorBravo`.
     * - `quorum=bravo` means that only For votes are counted towards quorum.
     * - `quorum=for,abstain` means that both For and Abstain votes are counted towards quorum.
     *
     * NOTE: The string can be decoded by the standard
     * https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams[`URLSearchParams`]
     * JavaScript class.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual returns (string memory);

    /**
     * @notice module:core
     * @dev Hashing function used to (re)build the proposal id from the proposal details..
     */
    function hashProposal(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Current state of a proposal, following Compound's convention
     */
    function state(uint256 proposalId) public view virtual returns (ProposalState);

    /**
     * @notice module:core
     * @dev Block number used to retrieve user's votes and quorum. As per Compound's Comp and OpenZeppelin's
     * ERC20Votes, the snapshot is performed at the end of this block. Hence, voting for this proposal starts at the
     * beginning of the following block.
     */
    function proposalSnapshot(uint256 proposalId) public view virtual returns (uint256);

    /**
     * @notice module:core
     * @dev Block number at which votes close. Votes close at the end of this block, so it is possible to cast a vote
     * during this block.
     */
    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Delay, in number of block, between the proposal is created and the vote starts. This can be increassed to
     * leave time for users to buy voting power, of delegate it, before the voting of a proposal starts.
     */
    function votingDelay() public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Delay, in number of blocks, between the vote start and vote ends.
     *
     * NOTE: The {votingDelay} can delay the start of the vote. This must be considered when setting the voting
     * duration compared to the voting delay.
     */
    function votingPeriod() public view virtual returns (uint256);

    /**
     * @notice module:user-config
     * @dev Minimum number of cast voted required for a proposal to be successful.
     *
     * Note: The `blockNumber` parameter corresponds to the snaphot used for counting vote. This allows to scale the
     * quroum depending on values such as the totalSupply of a token at this block (see {ERC20Votes}).
     */
    function quorum(uint256 blockNumber) public view virtual returns (uint256);

    /**
     * @notice module:reputation
     * @dev Voting power of an `account` at a specific `blockNumber`.
     *
     * Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or
     * multiple), {ERC20Votes} tokens.
     */
    function getVotes(address account, uint256 blockNumber) public view virtual returns (uint256);

    /**
     * @notice module:voting
     * @dev Returns weither `account` has cast a vote on `proposalId`.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual returns (bool);

    /**
     * @dev Create a new proposal. Vote start {IGovernor-votingDelay} blocks after the proposal is created and ends
     * {IGovernor-votingPeriod} blocks after the voting starts.
     *
     * Emits a {ProposalCreated} event.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual returns (uint256 proposalId);

    /**
     * @dev Execute a successful proposal. This requires the quorum to be reached, the vote to be successful, and the
     * deadline to be reached.
     *
     * Emits a {ProposalExecuted} event.
     *
     * Note: some module can modify the requirements for execution, for example by adding an additional timelock.
     */
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual returns (uint256 proposalId);

    /**
     * @dev Cast a vote
     *
     * Emits a {VoteCast} event.
     */
    function castVote(uint256 proposalId, uint8 support) public virtual returns (uint256 balance);

    /**
     * @dev Cast a with a reason
     *
     * Emits a {VoteCast} event.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) public virtual returns (uint256 balance);

    /**
     * @dev Cast a vote using the user cryptographic signature.
     *
     * Emits a {VoteCast} event.
     */
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual returns (uint256 balance);
}


// File @openzeppelin/contracts/governance/Governor.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/Governor.sol)

pragma solidity ^0.8.0;








/**
 * @dev Core of the governance system, designed to be extended though various modules.
 *
 * This contract is abstract and requires several function to be implemented in various modules:
 *
 * - A counting module must implement {quorum}, {_quorumReached}, {_voteSucceeded} and {_countVote}
 * - A voting module must implement {getVotes}
 * - Additionanly, the {votingPeriod} must also be implemented
 *
 * _Available since v4.3._
 */
abstract contract Governor is Context, ERC165, EIP712, IGovernor {
    using SafeCast for uint256;
    using Timers for Timers.BlockNumber;

    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint8 support)");

    struct ProposalCore {
        Timers.BlockNumber voteStart;
        Timers.BlockNumber voteEnd;
        bool executed;
        bool canceled;
    }

    string private _name;

    mapping(uint256 => ProposalCore) private _proposals;

    /**
     * @dev Restrict access to governor executing address. Some module might override the _executor function to make
     * sure this modifier is consistant with the execution model.
     */
    modifier onlyGovernance() {
        require(_msgSender() == _executor(), "Governor: onlyGovernance");
        _;
    }

    /**
     * @dev Sets the value for {name} and {version}
     */
    constructor(string memory name_) EIP712(name_, version()) {
        _name = name_;
    }

    /**
     * @dev Function to receive ETH that will be handled by the governor (disabled if executor is a third party contract)
     */
    receive() external payable virtual {
        require(_executor() == address(this));
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IGovernor).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IGovernor-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IGovernor-version}.
     */
    function version() public view virtual override returns (string memory) {
        return "1";
    }

    /**
     * @dev See {IGovernor-hashProposal}.
     *
     * The proposal id is produced by hashing the RLC encoded `targets` array, the `values` array, the `calldatas` array
     * and the descriptionHash (bytes32 which itself is the keccak256 hash of the description string). This proposal id
     * can be produced from the proposal data which is part of the {ProposalCreated} event. It can even be computed in
     * advance, before the proposal is submitted.
     *
     * Note that the chainId and the governor address are not part of the proposal id computation. Consequently, the
     * same proposal (with same operation and same description) will have the same id if submitted on multiple governors
     * accross multiple networks. This also means that in order to execute the same operation twice (on the same
     * governor) the proposer will have to change the description in order to avoid proposal id conflicts.
     */
    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public pure virtual override returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

    /**
     * @dev See {IGovernor-state}.
     */
    function state(uint256 proposalId) public view virtual override returns (ProposalState) {
        ProposalCore memory proposal = _proposals[proposalId];

        if (proposal.executed) {
            return ProposalState.Executed;
        } else if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (proposal.voteStart.getDeadline() >= block.number) {
            return ProposalState.Pending;
        } else if (proposal.voteEnd.getDeadline() >= block.number) {
            return ProposalState.Active;
        } else if (proposal.voteEnd.isExpired()) {
            return
                _quorumReached(proposalId) && _voteSucceeded(proposalId)
                    ? ProposalState.Succeeded
                    : ProposalState.Defeated;
        } else {
            revert("Governor: unknown proposal id");
        }
    }

    /**
     * @dev See {IGovernor-proposalSnapshot}.
     */
    function proposalSnapshot(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteStart.getDeadline();
    }

    /**
     * @dev See {IGovernor-proposalDeadline}.
     */
    function proposalDeadline(uint256 proposalId) public view virtual override returns (uint256) {
        return _proposals[proposalId].voteEnd.getDeadline();
    }

    /**
     * @dev Part of the Governor Bravo's interface: _"The number of votes required in order for a voter to become a proposer"_.
     */
    function proposalThreshold() public view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Amount of votes already cast passes the threshold limit.
     */
    function _quorumReached(uint256 proposalId) internal view virtual returns (bool);

    /**
     * @dev Is the proposal successful or not.
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual returns (bool);

    /**
     * @dev Register a vote with a given support and voting weight.
     *
     * Note: Support is generic and can represent various things depending on the voting system used.
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal virtual;

    /**
     * @dev See {IGovernor-propose}.
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual override returns (uint256) {
        require(
            getVotes(msg.sender, block.number - 1) >= proposalThreshold(),
            "GovernorCompatibilityBravo: proposer votes below proposal threshold"
        );

        uint256 proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        require(targets.length == values.length, "Governor: invalid proposal length");
        require(targets.length == calldatas.length, "Governor: invalid proposal length");
        require(targets.length > 0, "Governor: empty proposal");

        ProposalCore storage proposal = _proposals[proposalId];
        require(proposal.voteStart.isUnset(), "Governor: proposal already exists");

        uint64 snapshot = block.number.toUint64() + votingDelay().toUint64();
        uint64 deadline = snapshot + votingPeriod().toUint64();

        proposal.voteStart.setDeadline(snapshot);
        proposal.voteEnd.setDeadline(deadline);

        emit ProposalCreated(
            proposalId,
            _msgSender(),
            targets,
            values,
            new string[](targets.length),
            calldatas,
            snapshot,
            deadline,
            description
        );

        return proposalId;
    }

    /**
     * @dev See {IGovernor-execute}.
     */
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual override returns (uint256) {
        uint256 proposalId = hashProposal(targets, values, calldatas, descriptionHash);

        ProposalState status = state(proposalId);
        require(
            status == ProposalState.Succeeded || status == ProposalState.Queued,
            "Governor: proposal not successful"
        );
        _proposals[proposalId].executed = true;

        emit ProposalExecuted(proposalId);

        _execute(proposalId, targets, values, calldatas, descriptionHash);

        return proposalId;
    }

    /**
     * @dev Internal execution mechanism. Can be overriden to implement different execution mechanism
     */
    function _execute(
        uint256, /* proposalId */
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 /*descriptionHash*/
    ) internal virtual {
        string memory errorMessage = "Governor: call reverted without message";
        for (uint256 i = 0; i < targets.length; ++i) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            Address.verifyCallResult(success, returndata, errorMessage);
        }
    }

    /**
     * @dev Internal cancel mechanism: locks up the proposal timer, preventing it from being re-submitted. Marks it as
     * canceled to allow distinguishing it from executed proposals.
     *
     * Emits a {IGovernor-ProposalCanceled} event.
     */
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual returns (uint256) {
        uint256 proposalId = hashProposal(targets, values, calldatas, descriptionHash);
        ProposalState status = state(proposalId);

        require(
            status != ProposalState.Canceled && status != ProposalState.Expired && status != ProposalState.Executed,
            "Governor: proposal not active"
        );
        _proposals[proposalId].canceled = true;

        emit ProposalCanceled(proposalId);

        return proposalId;
    }

    /**
     * @dev See {IGovernor-castVote}.
     */
    function castVote(uint256 proposalId, uint8 support) public virtual override returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, support, "");
    }

    /**
     * @dev See {IGovernor-castVoteWithReason}.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) public virtual override returns (uint256) {
        address voter = _msgSender();
        return _castVote(proposalId, voter, support, reason);
    }

    /**
     * @dev See {IGovernor-castVoteBySig}.
     */
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override returns (uint256) {
        address voter = ECDSA.recover(
            _hashTypedDataV4(keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, support))),
            v,
            r,
            s
        );
        return _castVote(proposalId, voter, support, "");
    }

    /**
     * @dev Internal vote casting mechanism: Check that the vote is pending, that it has not been cast yet, retrieve
     * voting weight using {IGovernor-getVotes} and call the {_countVote} internal function.
     *
     * Emits a {IGovernor-VoteCast} event.
     */
    function _castVote(
        uint256 proposalId,
        address account,
        uint8 support,
        string memory reason
    ) internal virtual returns (uint256) {
        ProposalCore storage proposal = _proposals[proposalId];
        require(state(proposalId) == ProposalState.Active, "Governor: vote not currently active");

        uint256 weight = getVotes(account, proposal.voteStart.getDeadline());
        _countVote(proposalId, account, support, weight);

        emit VoteCast(account, proposalId, support, weight, reason);

        return weight;
    }

    /**
     * @dev Address through which the governor executes action. Will be overloaded by module that execute actions
     * through another contract such as a timelock.
     */
    function _executor() internal view virtual returns (address) {
        return address(this);
    }
}


// File @openzeppelin/contracts/governance/extensions/GovernorSettings.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/extensions/GovernorSettings.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of {Governor} for settings updatable through governance.
 *
 * _Available since v4.4._
 */
abstract contract GovernorSettings is Governor {
    uint256 private _votingDelay;
    uint256 private _votingPeriod;
    uint256 private _proposalThreshold;

    event VotingDelaySet(uint256 oldVotingDelay, uint256 newVotingDelay);
    event VotingPeriodSet(uint256 oldVotingPeriod, uint256 newVotingPeriod);
    event ProposalThresholdSet(uint256 oldProposalThreshold, uint256 newProposalThreshold);

    /**
     * @dev Initialize the governance parameters.
     */
    constructor(
        uint256 initialVotingDelay,
        uint256 initialVotingPeriod,
        uint256 initialProposalThreshold
    ) {
        _setVotingDelay(initialVotingDelay);
        _setVotingPeriod(initialVotingPeriod);
        _setProposalThreshold(initialProposalThreshold);
    }

    /**
     * @dev See {IGovernor-votingDelay}.
     */
    function votingDelay() public view virtual override returns (uint256) {
        return _votingDelay;
    }

    /**
     * @dev See {IGovernor-votingPeriod}.
     */
    function votingPeriod() public view virtual override returns (uint256) {
        return _votingPeriod;
    }

    /**
     * @dev See {Governor-proposalThreshold}.
     */
    function proposalThreshold() public view virtual override returns (uint256) {
        return _proposalThreshold;
    }

    /**
     * @dev Update the voting delay. This operation can only be performed through a governance proposal.
     *
     * Emits a {VotingDelaySet} event.
     */
    function setVotingDelay(uint256 newVotingDelay) public virtual onlyGovernance {
        _setVotingDelay(newVotingDelay);
    }

    /**
     * @dev Update the voting period. This operation can only be performed through a governance proposal.
     *
     * Emits a {VotingPeriodSet} event.
     */
    function setVotingPeriod(uint256 newVotingPeriod) public virtual onlyGovernance {
        _setVotingPeriod(newVotingPeriod);
    }

    /**
     * @dev Update the proposal threshold. This operation can only be performed through a governance proposal.
     *
     * Emits a {ProposalThresholdSet} event.
     */
    function setProposalThreshold(uint256 newProposalThreshold) public virtual onlyGovernance {
        _setProposalThreshold(newProposalThreshold);
    }

    /**
     * @dev Internal setter for the voting delay.
     *
     * Emits a {VotingDelaySet} event.
     */
    function _setVotingDelay(uint256 newVotingDelay) internal virtual {
        emit VotingDelaySet(_votingDelay, newVotingDelay);
        _votingDelay = newVotingDelay;
    }

    /**
     * @dev Internal setter for the voting period.
     *
     * Emits a {VotingPeriodSet} event.
     */
    function _setVotingPeriod(uint256 newVotingPeriod) internal virtual {
        // voting period must be at least one block long
        require(newVotingPeriod > 0, "GovernorSettings: voting period too low");
        emit VotingPeriodSet(_votingPeriod, newVotingPeriod);
        _votingPeriod = newVotingPeriod;
    }

    /**
     * @dev Internal setter for the proposal threshold.
     *
     * Emits a {ProposalThresholdSet} event.
     */
    function _setProposalThreshold(uint256 newProposalThreshold) internal virtual {
        emit ProposalThresholdSet(_proposalThreshold, newProposalThreshold);
        _proposalThreshold = newProposalThreshold;
    }
}


// File @openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/extensions/GovernorCountingSimple.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of {Governor} for simple, 3 options, vote counting.
 *
 * _Available since v4.3._
 */
abstract contract GovernorCountingSimple is Governor {
    /**
     * @dev Supported vote types. Matches Governor Bravo ordering.
     */
    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => ProposalVote) private _proposalVotes;

    /**
     * @dev See {IGovernor-COUNTING_MODE}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=for,abstain";
    }

    /**
     * @dev See {IGovernor-hasVoted}.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual override returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @dev Accessor to the internal vote counts.
     */
    function proposalVotes(uint256 proposalId)
        public
        view
        virtual
        returns (
            uint256 againstVotes,
            uint256 forVotes,
            uint256 abstainVotes
        )
    {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];
        return (proposalvote.againstVotes, proposalvote.forVotes, proposalvote.abstainVotes);
    }

    /**
     * @dev See {Governor-_quorumReached}.
     */
    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];

        return quorum(proposalSnapshot(proposalId)) <= proposalvote.forVotes + proposalvote.abstainVotes;
    }

    /**
     * @dev See {Governor-_voteSucceeded}. In this module, the forVotes must be strictly over the againstVotes.
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];

        return proposalvote.forVotes > proposalvote.againstVotes;
    }

    /**
     * @dev See {Governor-_countVote}. In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal virtual override {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];

        require(!proposalvote.hasVoted[account], "GovernorVotingSimple: vote already cast");
        proposalvote.hasVoted[account] = true;

        if (support == uint8(VoteType.Against)) {
            proposalvote.againstVotes += weight;
        } else if (support == uint8(VoteType.For)) {
            proposalvote.forVotes += weight;
        } else if (support == uint8(VoteType.Abstain)) {
            proposalvote.abstainVotes += weight;
        } else {
            revert("GovernorVotingSimple: invalid value for enum VoteType");
        }
    }
}


// File @openzeppelin/contracts/governance/extensions/GovernorVotes.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/extensions/GovernorVotes.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {Governor} for voting weight extraction from an {ERC20Votes} token.
 *
 * _Available since v4.3._
 */
abstract contract GovernorVotes is Governor {
    ERC20Votes public immutable token;

    constructor(ERC20Votes tokenAddress) {
        token = tokenAddress;
    }

    /**
     * Read the voting weight from the token's built in snapshot mechanism (see {IGovernor-getVotes}).
     */
    function getVotes(address account, uint256 blockNumber) public view virtual override returns (uint256) {
        return token.getPastVotes(account, blockNumber);
    }
}


// File @openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/extensions/GovernorVotesQuorumFraction.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of {Governor} for voting weight extraction from an {ERC20Votes} token and a quorum expressed as a
 * fraction of the total supply.
 *
 * _Available since v4.3._
 */
abstract contract GovernorVotesQuorumFraction is GovernorVotes {
    uint256 private _quorumNumerator;

    event QuorumNumeratorUpdated(uint256 oldQuorumNumerator, uint256 newQuorumNumerator);

    constructor(uint256 quorumNumeratorValue) {
        _updateQuorumNumerator(quorumNumeratorValue);
    }

    function quorumNumerator() public view virtual returns (uint256) {
        return _quorumNumerator;
    }

    function quorumDenominator() public view virtual returns (uint256) {
        return 100;
    }

    function quorum(uint256 blockNumber) public view virtual override returns (uint256) {
        return (token.getPastTotalSupply(blockNumber) * quorumNumerator()) / quorumDenominator();
    }

    function updateQuorumNumerator(uint256 newQuorumNumerator) external virtual onlyGovernance {
        _updateQuorumNumerator(newQuorumNumerator);
    }

    function _updateQuorumNumerator(uint256 newQuorumNumerator) internal virtual {
        require(
            newQuorumNumerator <= quorumDenominator(),
            "GovernorVotesQuorumFraction: quorumNumerator over quorumDenominator"
        );

        uint256 oldQuorumNumerator = _quorumNumerator;
        _quorumNumerator = newQuorumNumerator;

        emit QuorumNumeratorUpdated(oldQuorumNumerator, newQuorumNumerator);
    }
}


// File @openzeppelin/contracts/governance/extensions/IGovernorTimelock.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/extensions/IGovernorTimelock.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of the {IGovernor} for timelock supporting modules.
 *
 * _Available since v4.3._
 */
abstract contract IGovernorTimelock is IGovernor {
    event ProposalQueued(uint256 proposalId, uint256 eta);

    function timelock() public view virtual returns (address);

    function proposalEta(uint256 proposalId) public view virtual returns (uint256);

    function queue(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public virtual returns (uint256 proposalId);
}


// File @openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/extensions/GovernorTimelockControl.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {Governor} that binds the execution process to an instance of {TimelockController}. This adds a
 * delay, enforced by the {TimelockController} to all successful proposal (in addition to the voting duration). The
 * {Governor} needs the proposer (an ideally the executor) roles for the {Governor} to work properly.
 *
 * Using this model means the proposal will be operated by the {TimelockController} and not by the {Governor}. Thus,
 * the assets and permissions must be attached to the {TimelockController}. Any asset sent to the {Governor} will be
 * inaccessible.
 *
 * _Available since v4.3._
 */
abstract contract GovernorTimelockControl is IGovernorTimelock, Governor {
    TimelockController private _timelock;
    mapping(uint256 => bytes32) private _timelockIds;

    /**
     * @dev Emitted when the timelock controller used for proposal execution is modified.
     */
    event TimelockChange(address oldTimelock, address newTimelock);

    /**
     * @dev Set the timelock.
     */
    constructor(TimelockController timelockAddress) {
        _updateTimelock(timelockAddress);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, Governor) returns (bool) {
        return interfaceId == type(IGovernorTimelock).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Overriden version of the {Governor-state} function with added support for the `Queued` status.
     */
    function state(uint256 proposalId) public view virtual override(IGovernor, Governor) returns (ProposalState) {
        ProposalState status = super.state(proposalId);

        if (status != ProposalState.Succeeded) {
            return status;
        }

        // core tracks execution, so we just have to check if successful proposal have been queued.
        bytes32 queueid = _timelockIds[proposalId];
        if (queueid == bytes32(0)) {
            return status;
        } else if (_timelock.isOperationDone(queueid)) {
            return ProposalState.Executed;
        } else {
            return ProposalState.Queued;
        }
    }

    /**
     * @dev Public accessor to check the address of the timelock
     */
    function timelock() public view virtual override returns (address) {
        return address(_timelock);
    }

    /**
     * @dev Public accessor to check the eta of a queued proposal
     */
    function proposalEta(uint256 proposalId) public view virtual override returns (uint256) {
        uint256 eta = _timelock.getTimestamp(_timelockIds[proposalId]);
        return eta == 1 ? 0 : eta; // _DONE_TIMESTAMP (1) should be replaced with a 0 value
    }

    /**
     * @dev Function to queue a proposal to the timelock.
     */
    function queue(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public virtual override returns (uint256) {
        uint256 proposalId = hashProposal(targets, values, calldatas, descriptionHash);

        require(state(proposalId) == ProposalState.Succeeded, "Governor: proposal not successful");

        uint256 delay = _timelock.getMinDelay();
        _timelockIds[proposalId] = _timelock.hashOperationBatch(targets, values, calldatas, 0, descriptionHash);
        _timelock.scheduleBatch(targets, values, calldatas, 0, descriptionHash, delay);

        emit ProposalQueued(proposalId, block.timestamp + delay);

        return proposalId;
    }

    /**
     * @dev Overriden execute function that run the already queued proposal through the timelock.
     */
    function _execute(
        uint256, /* proposalId */
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override {
        _timelock.executeBatch{value: msg.value}(targets, values, calldatas, 0, descriptionHash);
    }

    /**
     * @dev Overriden version of the {Governor-_cancel} function to cancel the timelocked proposal if it as already
     * been queued.
     */
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual override returns (uint256) {
        uint256 proposalId = super._cancel(targets, values, calldatas, descriptionHash);

        if (_timelockIds[proposalId] != 0) {
            _timelock.cancel(_timelockIds[proposalId]);
            delete _timelockIds[proposalId];
        }

        return proposalId;
    }

    /**
     * @dev Address through which the governor executes action. In this case, the timelock.
     */
    function _executor() internal view virtual override returns (address) {
        return address(_timelock);
    }

    /**
     * @dev Public endpoint to update the underlying timelock instance. Restricted to the timelock itself, so updates
     * must be proposed, scheduled and executed using the {Governor} workflow.
     */
    function updateTimelock(TimelockController newTimelock) external virtual onlyGovernance {
        _updateTimelock(newTimelock);
    }

    function _updateTimelock(TimelockController newTimelock) private {
        emit TimelockChange(address(_timelock), address(newTimelock));
        _timelock = newTimelock;
    }
}


// File contracts/DAO/MelodityDAO.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;






contract MelodityDAO is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction, GovernorTimelockControl {
    constructor(ERC20Votes _token, TimelockController _timelock)
        Governor("Melodity DAO")
        GovernorSettings(
			1,					// vote starts after 1 block  
			45818, 				// voting period lasts 1 week
			0					// minium gMELD to run a proposal
		)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {}

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function getVotes(address account, uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotes)
        returns (uint256)
    {
        return super.getVotes(account, blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


// File @openzeppelin/contracts/security/Pausable.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File contracts/IStackingPanda.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;


abstract contract IStackingPanda {
    function computeStackingPandaAddress(address _masterchef)
        internal
        pure
        returns (address)
    {
        return
            Create2.computeAddress(
                keccak256("Masterchef/StackingPanda"),
                keccak256(type(StackingPanda).creationCode),
                _masterchef
            );
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol@v4.4.1

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}


// File contracts/Stacking/StackingReceipt.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;




/**
	@author Emanuele (ebalo) Balsamo
	
	Stacking receipt contract developed to be easily instantiable with
	custom data.

	Most functions are reserved to the owner as this reduces the possibility
	to lock funds in stacking pools. 
	User can always transfer funds actually being able to use any aggregator,
	or yield optimizer.
 */
contract StackingReceipt is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor(string memory _name, string memory _ticker)
        ERC20(_name, _ticker)
        ERC20Permit(_name)
    {}

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
}


// File contracts/Stacking/MelodityStacking.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;











/**
	@author Emanuele (ebalo) Balsamo
	@custom:security-contact security@melodity.org
 */
contract MelodityStacking is IPRNG, IStackingPanda, ERC721Holder, Ownable, Pausable, ReentrancyGuard {
	bytes4 constant public _INTERFACE_ID_ERC20_METADATA = 0x942e8b22;
	address constant public _DO_INC_MULTISIG_WALLET = 0x01Af10f1343C05855955418bb99302A6CF71aCB8;
	uint256 constant public _PERCENTAGE_SCALE = 10 ** 20;
	uint256 constant public _EPOCH_DURATION = 1 hours;

	/**
		@param startingTime Era starting time
		@param eraDuration Era duration (in seconds)
		@param rewardScaleFactor Factor that the current reward will be
		 		multiplied to at the end of the current era
		@param eraScaleFactor Factor that the current era duration will be
				multiplied to at the end of the current era
	 */
	struct EraInfo {
		uint256 startingTime;
		uint256 eraDuration;
		uint256 rewardScaleFactor;
		uint256 eraScaleFactor;
		uint256 rewardFactorPerEpoch;
	}

	/**
		@param rewardPool Amount of MELD yet to distribute from this stacking contract
		@param receiptValue Receipt token value
		@param lastReceiptUpdateTime Last update time of the receipt value
		@param eraDuration First era duration misured in seconds
		@param genesisEraDuration Contract genesis timestamp, used to start eras calculation
		@param genesisRewardScaleFactor Contract genesis reward scaling factor
		@param genesisEraScaleFactor Contract genesis era scaling factor
	 */
	struct PoolInfo {
		uint256 rewardPool;
		uint256 receiptValue;
		uint256 lastReceiptUpdateTime;
		uint256 genesisEraDuration;
		uint256 genesisTime;
		uint256 genesisRewardScaleFactor;
		uint256 genesisEraScaleFactor;
		uint256 genesisRewardFactorPerEpoch;
		bool exhausting;
		bool dismissed;
	}

	/**
		@param maxFeePercentage Max fee if withdraw occurr before withdrawFeePeriod days
		@param minFeePercentage Min fee if withdraw occurr before withdrawFeePeriod days
		@param feePercentage Currently applied fee percentage for early withdraw
		@param feeReceiver Address where the fees gets sent
		@param withdrawFeePeriod Number of days or hours that a deposit is considered to 
				under the withdraw with fee period
		@param feeReceiverPercentage Share of the fee that goes to the feeReceiver
		@param feeMaintainerPercentage Share of the fee that goes to the _DO_INC_MULTISIG_WALLET
		@param feeReceiverMinPercent Minimum percentage that can be given to the feeReceiver
		@param feeMaintainerMinPercent Minimum percentage that can be given to the _DO_INC_MULTISIG_WALLET
	 */
	struct FeeInfo {
		uint256 maxFeePercentage;
		uint256 minFeePercentage;
		uint256 feePercentage;
		address feeReceiver;
		uint256 withdrawFeePeriod;
		uint256 feeReceiverPercentage;
		uint256 feeMaintainerPercentage;
		uint256 feeReceiverMinPercent;
		uint256 feeMaintainerMinPercent;
	}

	/**
		@param stackedAmount Amount of receipt received during the stacking deposit, in order to withdraw the NFT this
				value *MUST* be zero
		@param nftId NFT identifier
	 */
	struct StackedNFT {
		uint256 stackedAmount;
		uint256 nftId;
	}

	/**
		+-------------------+ 
	 	|  Stacking values  |
	 	+-------------------+
		@notice funds must be sent to this address in order to actually start rewarding
				users

		@dev poolInfo: pool information container
		@dev eraInfos: array of EraInfo where startingTime, endingTime, rewardPerEpoch
				and eraDuration gets defined in a per era basis
		@dev stackersLastDeposit: stacker last executed deposit, reset at each deposit
		@dev stackedNFTs: Association between an address and its stacked NFTs
		@dev depositorNFT: Association between an NFT identifier and the depositor address
	*/
	PoolInfo public poolInfo;
	FeeInfo public feeInfo;
	EraInfo[] public eraInfos;
	mapping(address => uint256) private stackersLastDeposit;
	mapping(address => StackedNFT[]) public stackedNFTs;
	mapping(uint256 => address) public depositorNFT;

    ERC20 public melodity;
	StackingReceipt public stackingReceipt;
    PRNG public prng;
	StackingPanda public stackingPanda;

	event Deposit(address account, uint256 amount, uint256 receiptAmount, uint256 depositTime);
	event NFTDeposit(address account, uint256 nftId);
	event ReceiptValueUpdate(uint256 value);
	event Withdraw(address account, uint256 amount, uint256 receiptAmount);
	event NFTWithdraw(address account, uint256 nftId);
	event FeePaid(uint256 amount, uint256 receiptAmount);
	event RewardPoolIncreased(uint256 insertedAmount);
	event PoolExhausting(uint256 amountLeft);
	event EraDurationUpdate(uint256 oldDuration, uint256 newDuration);
	event RewardScalingFactorUpdate(uint256 oldFactor, uint256 newFactor);
	event EraScalingFactorUpdate(uint256 oldFactor, uint256 newFactor);
	event EarlyWithdrawFeeUpdate(uint256 oldFactor, uint256 newFactor);
	event FeeReceiverUpdate(address _old, address _new);
	event WithdrawPeriodUpdate(uint256 oldPeriod, uint256 newPeriod);
	event DaoFeeSharedUpdate(uint256 oldShare, uint256 newShare);
	event MaintainerFeeSharedUpdate(uint256 oldShare, uint256 newShare);
	event PoolDismissed();

	/**
		Initialize the values of the stacking contract

		@param _masterchef The masterchef generator contract address,
			it deploies other contracts
		@param _melodity Melodity ERC20 contract address
	 */
    constructor(address _masterchef, address _melodity, address _dao, uint8 _erasToGenerate) {
		prng = PRNG(computePRNGAddress(_masterchef));
		stackingPanda = StackingPanda(computeStackingPandaAddress(_masterchef));
		melodity = ERC20(_melodity);
		stackingReceipt = new StackingReceipt("Melodity stacking receipt", "sMELD");
		
		poolInfo = PoolInfo({
			rewardPool: 20_000_000 ether,
			receiptValue: 1 ether,
			lastReceiptUpdateTime: block.timestamp,
			genesisEraDuration: 720 * _EPOCH_DURATION,
			genesisTime: block.timestamp,
			genesisRewardScaleFactor: 79 ether,
			genesisEraScaleFactor: 107 ether,
			genesisRewardFactorPerEpoch: 0.001 ether,
			exhausting: false,
			dismissed: false
		});

		feeInfo = FeeInfo({
			maxFeePercentage: 10 ether,
			minFeePercentage: 0.1 ether,
			feePercentage: 10 ether,
			feeReceiver: _dao,
			withdrawFeePeriod: 7 days,
			feeReceiverPercentage: 5 ether,
			feeMaintainerPercentage: 95 ether,
			feeReceiverMinPercent: 5 ether,
			feeMaintainerMinPercent: 25 ether
		});

		_triggerErasInfoRefresh(_erasToGenerate);
    }

	function getEraInfosLength() public view returns(uint256) {
		return eraInfos.length;
	}

	/**
		Trigger the regeneration of _erasToGenerate (at most 128) eras from the current
		one.
		The regenerated eras will use the latest defined eraScaleFactor and rewardScaleFactor
		to compute the eras duration and reward.
		Playing around with the number of eras and the scaling factor caller by this method can
		(re-)generate an arbitrary number of eras (not already started) increasing or decreasing 
		their rewardScaleFactor and eraScaleFactor

		@notice This method overwrites the next era definition first, then moves adding new eras
		@param _erasToGenerate Number of eras to (re-)generate
	 */
	function _triggerErasInfoRefresh(uint8 _erasToGenerate) private {
		uint256 existingErasInfos = eraInfos.length;
		uint256 i;
		uint256 k;

		while(i < _erasToGenerate) {
			// check if exists some era infos, if they exists check if the k-th era is already started
			// if it is already started it cannot be edited and we won't consider it actually increasing 
			// k
			if(existingErasInfos > k && eraInfos[k].startingTime <= block.timestamp) {
				k++;
			}
			// if the era is not yet started we can modify its values
			else if(existingErasInfos > k && eraInfos[k].startingTime > block.timestamp) {
				// get the genesis value or the last one available.
				// NOTE: as this is a modification of existing values the last available value before
				// 		the curren one is stored as the (k-1)-th element of the eraInfos array
				uint256 lastTimestamp = k == 0 ? poolInfo.genesisTime : eraInfos[k - 1].startingTime + eraInfos[k - 1].eraDuration;
				uint256 lastEraDuration = k == 0 ? poolInfo.genesisEraDuration : eraInfos[k - 1].eraDuration;
				uint256 lastEraScalingFactor = k == 0 ? poolInfo.genesisEraScaleFactor : eraInfos[k - 1].eraScaleFactor;
				uint256 lastRewardScalingFactor = k == 0 ? poolInfo.genesisRewardScaleFactor : eraInfos[k - 1].rewardScaleFactor;
				uint256 lastEpochRewardFactor = k == 0 ? poolInfo.genesisRewardFactorPerEpoch : eraInfos[k - 1].rewardFactorPerEpoch;

				uint256 newEraDuration = k != 0 ? lastEraDuration * lastEraScalingFactor / _PERCENTAGE_SCALE : poolInfo.genesisEraDuration;
				eraInfos[k] = EraInfo({
					// new eras starts always the second after the ending of the previous
					// if era-1 ends at sec 1234 era-2 will start at sec 1235
					startingTime: lastTimestamp + 1,
					eraDuration: newEraDuration,
					rewardScaleFactor: lastRewardScalingFactor,
					eraScaleFactor: lastEraScalingFactor,
					rewardFactorPerEpoch: k != 0 ? lastEpochRewardFactor * lastRewardScalingFactor / _PERCENTAGE_SCALE : poolInfo.genesisRewardFactorPerEpoch
				});

				// as an era was just updated increase the i counter
				i++;
				// in order to move to the next era or start creating a new one we also need to increase
				// k counter
				k++;
			}
			// start generating new eras info if the number of existing eras is equal to the last computed
			else if(existingErasInfos == k) {
				// get the genesis value or the last one available
				uint256 lastTimestamp = k == 0 ? poolInfo.genesisTime : eraInfos[k - 1].startingTime + eraInfos[k - 1].eraDuration;
				uint256 lastEraDuration = k == 0 ? poolInfo.genesisEraDuration : eraInfos[k - 1].eraDuration;
				uint256 lastEraScalingFactor = k == 0 ? poolInfo.genesisEraScaleFactor : eraInfos[k - 1].eraScaleFactor;
				uint256 lastRewardScalingFactor = k == 0 ? poolInfo.genesisRewardScaleFactor : eraInfos[k - 1].rewardScaleFactor;
				uint256 lastEpochRewardFactor = k == 0 ? poolInfo.genesisRewardFactorPerEpoch : eraInfos[k - 1].rewardFactorPerEpoch;

				uint256 newEraDuration = k != 0 ? lastEraDuration * lastEraScalingFactor / _PERCENTAGE_SCALE : poolInfo.genesisEraDuration;
				eraInfos.push(EraInfo({
					// new eras starts always the second after the ending of the previous
					// if era-1 ends at sec 1234 era-2 will start at sec 1235
					startingTime: lastTimestamp + 1,
					eraDuration: newEraDuration,
					rewardScaleFactor: lastRewardScalingFactor,
					eraScaleFactor: lastEraScalingFactor,
					rewardFactorPerEpoch: k != 0 ? lastEpochRewardFactor * lastRewardScalingFactor / _PERCENTAGE_SCALE : poolInfo.genesisRewardFactorPerEpoch
				}));

				// as an era was just created increase the i counter
				i++;
				// in order to move to the next era and start creating a new one we also need to increase
				// k counter and the existingErasInfos counter
				existingErasInfos = eraInfos.length;
				k++;
			}
		}
	}

	/**
		Deposit the provided MELD into the stacking pool

		@param _amount Amount of MELD that will be stacked
	 */
	function deposit(uint256 _amount) public nonReentrant whenNotPaused returns(uint256) {
		return _deposit(_amount);
	}

	/**
		Deposit the provided MELD into the stacking pool

		@notice private function to avoid reentrancy guard triggering

		@param _amount Amount of MELD that will be stacked
	 */
	function _deposit(uint256 _amount) private returns(uint256) {
		prng.rotate();

		require(_amount > 0, "Unable to deposit null amount");
		require(melodity.balanceOf(msg.sender) >= _amount, "Not enough balance to stake");
		require(melodity.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

		refreshReceiptValue();

		// transfer the funds from the sender to the stacking contract, the contract balance will
		// increase but the reward pool will not
		melodity.transferFrom(msg.sender, address(this), _amount);

		// update the last deposit time, reset the withdraw fee timer
		stackersLastDeposit[msg.sender] = block.timestamp;

		// mint the stacking receipt to the depositor
		uint256 receiptAmount = _amount * 1 ether / poolInfo.receiptValue ;
		stackingReceipt.mint(msg.sender, receiptAmount);

		emit Deposit(msg.sender, _amount, receiptAmount, block.timestamp);

		return receiptAmount;
	}

	/**
		Deposit the provided MELD into the stacking pool.
		This method deposits also the provided NFT into the stacking pool and mints the bonus receipts
		to the stacker

		@param _amount Amount of MELD that will be stacked
		@param _nftId NFT identifier that will be stacked with the funds
	 */
	function depositWithNFT(uint256 _amount, uint256 _nftId) public nonReentrant whenNotPaused {
		prng.rotate();

		require(stackingPanda.ownerOf(_nftId) == msg.sender, "You're not the owner of the provided NFT");
		require(stackingPanda.getApproved(_nftId) == address(this), "Stacking pool not allowed to withdraw your NFT");

		// withdraw the nft from the sender
		stackingPanda.safeTransferFrom(msg.sender, address(this), _nftId);
		StackingPanda.Metadata memory metadata = stackingPanda.getMetadata(_nftId);

		// make a standard deposit with the funds
		uint256 receipt = _deposit(_amount);

		// compute and mint the stacking receipt of the bonus given by the NFT
		uint256 bonusAmount = _amount * metadata.bonus.meldToMeld / _PERCENTAGE_SCALE;
		uint256 receiptAmount = bonusAmount * 1 ether / poolInfo.receiptValue;
		stackingReceipt.mint(msg.sender, receiptAmount);
		
		// In order to withdraw the nft the stacked amount for the given NFT *MUST* be zero
		stackedNFTs[msg.sender].push(StackedNFT({
			stackedAmount: receipt + receiptAmount,
			nftId: _nftId
		}));
		depositorNFT[_nftId] = msg.sender;

		emit NFTDeposit(msg.sender, _nftId);
	}

	/**
		Withdraw the receipt from the pool

		@param _amount Receipt amount to reconvert to MELD
	 */
	function withdraw(uint256 _amount) public nonReentrant {
		return _withdraw(_amount);
    }

	/**
		Withdraw the receipt from the pool

		@notice private function to avoid reentrancy guard triggering

		@param _amount Receipt amount to reconvert to MELD
	 */
	function _withdraw(uint256 _amount) private {
		prng.rotate();

        require(_amount > 0, "Nothing to withdraw");
		require(
			stackingReceipt.balanceOf(msg.sender) >= _amount,
			"Not enought receipt to widthdraw"
		);
		require(
			stackingReceipt.allowance(msg.sender, address(this)) >= _amount,
			"Stacking pool not allowed to withdraw enough of you receipt"
		);

		refreshReceiptValue();

		// burn the receipt from the sender address
        stackingReceipt.burnFrom(msg.sender, _amount);

		uint256 meldToWithdraw = _amount * poolInfo.receiptValue / 1 ether;

		// reduce the reward pool
		poolInfo.rewardPool -= meldToWithdraw;
		_checkIfExhausting();

		uint256 lastAction = stackersLastDeposit[msg.sender];
		uint256 _now = block.timestamp;

		// check if the last deposit was done at least feeInfo.withdrawFeePeriod seconds
		// in the past, if it was then the user has no fee to pay for the withdraw
		// proceed with a direct transfer of the balance needed
		if(lastAction < _now && lastAction + feeInfo.withdrawFeePeriod < _now) {
			melodity.transfer(msg.sender, meldToWithdraw);
			emit Withdraw(msg.sender, meldToWithdraw, _amount);
		}
		// user have to pay withdraw fee
		else {
			uint256 fee = meldToWithdraw * feeInfo.feePercentage / _PERCENTAGE_SCALE;
			// deduct fee from the amount to withdraw
			meldToWithdraw -= fee;

			// split fee with dao and maintainer
			uint256 daoFee = fee * feeInfo.feeReceiverPercentage / _PERCENTAGE_SCALE;
			uint256 maintainerFee = fee - daoFee;

			melodity.transfer(feeInfo.feeReceiver, daoFee);
			melodity.transfer(_DO_INC_MULTISIG_WALLET, maintainerFee);
			emit FeePaid(fee, fee * poolInfo.receiptValue);

			melodity.transfer(msg.sender, meldToWithdraw);
			emit Withdraw(msg.sender, meldToWithdraw, _amount);
		}
    }

	/**
		Withdraw the receipt and the deposited NFT (if possible) from the stacking pool

		@notice Withdrawing an amount higher then the deposited one and having more than
				one NFT stacked may lead to the permanent lock of the NFT in the contract.
				The NFT may be retrieved re-providing the funds for stacking and withdrawing
				the required amount of funds using this method

		@param _amount Receipt amount to reconvert to MELD
		@param _index Index of the stackedNFTs array whose NFT will be recovered if possible
	 */
	function withdrawWithNFT(uint256 _amount, uint256 _index) public nonReentrant {
		prng.rotate();
		
		require(stackedNFTs[msg.sender].length > _index, "Index out of bound");

		// run the standard withdraw
		_withdraw(_amount);

		StackedNFT storage stackedNFT = stackedNFTs[msg.sender][_index];

		// if the amount withdrawn is greater or equal to the stacked amount than allow the
		// withdraw of the NFT
		// ALERT: withdrawing an amount higher then the deposited one and having more than
		//		one NFT stacked may lead to the permanent lock of the NFT in the contract.
		//		The NFT may be retrieved re-providing the funds for stacking and withdrawing
		//		the required amount of funds using this method
		if(_amount >= stackedNFT.stackedAmount) {
			// avoid overflow with 1 nft only, swap the element and the latest one only
			// if the array has more than one element
			if(stackedNFTs[msg.sender].length -1 > 0) {
				stackedNFTs[msg.sender][_index] = stackedNFTs[msg.sender][stackedNFTs[msg.sender].length - 1];
			}
			// remove the element from the array
			stackedNFTs[msg.sender].pop();
			depositorNFT[stackedNFT.nftId] = address(0);

			// refund the NFT to the original owner
			stackingPanda.safeTransferFrom(address(this), msg.sender, stackedNFT.nftId);
			emit NFTWithdraw(msg.sender, stackedNFT.nftId);
		}
		// otherwise simply reduce the stacked amount by the withdrawn amount
		else {
			stackedNFT.stackedAmount -= _amount;
		}
	}

	/**
		Checks if the reward pool is less then 1mln MELD, if it is mark the pool
		as exhausting and emit the PoolExhausting event
	 */
	function _checkIfExhausting() private {
		if(poolInfo.rewardPool < 1_000_000 ether) {
			poolInfo.exhausting = true;
			emit PoolExhausting(poolInfo.rewardPool);
		}
	}

	/**
		Update the receipt value if necessary

		@notice This method *MUST* never be marked as nonReentrant as if no valid era was found it
				calls itself back after the generation of 2 new era infos
	 */
	function refreshReceiptValue() public {
		prng.rotate();

		uint256 _now = block.timestamp;
		uint256 lastUpdateTime = poolInfo.lastReceiptUpdateTime;
		require(lastUpdateTime < _now, "Receipt value already update in this transaction");

		poolInfo.lastReceiptUpdateTime = block.timestamp;

		uint256 eraEndingTime;
		bool validEraFound;

		for(uint256 i; i < eraInfos.length; i++) {
			eraEndingTime = eraInfos[i].startingTime + eraInfos[i].eraDuration;

			// check if the lastUpdateTime is inside the currently checking era
			if(eraInfos[i].startingTime <= lastUpdateTime && lastUpdateTime <= eraEndingTime) {
				// As there may be the case no valid era was still created and this branch will never enter
				// we use a boolean value to indicate if it was ever entered or not. as we're into the branch
				// we set is to true here
				validEraFound = true;

				// check if _now is in the same era of the lastUpdateTime, if it is then use _now to recompute the receipt value
				if(eraInfos[i].startingTime <= _now && _now <= eraEndingTime) {
					// NOTE: here some epochs may get lost as lastUpdateTime will almost never be equal to the exact epoch
					// 		update time, in order to avoid this error we compute the difference from the lastUpdateTime
					//		and the difference from the start of this era, as the two value will differ most of the times
					//		we compute the real number of epoch from the last fully completed one
					uint256 diffSinceLastUpdate = _now - lastUpdateTime;
					uint256 epochsSinceLastUpdate = diffSinceLastUpdate / _EPOCH_DURATION;

					uint256 diffSinceEraStart = _now - eraInfos[i].startingTime;
					uint256 epochsSinceEraStart = diffSinceEraStart / _EPOCH_DURATION;

					uint256 missingFullEpochs = epochsSinceLastUpdate;

					if(epochsSinceEraStart > epochsSinceLastUpdate) {
						missingFullEpochs = epochsSinceEraStart - epochsSinceLastUpdate;
					}

					// recompute the receipt value missingFullEpochs times
					while(missingFullEpochs > 0) {
						poolInfo.receiptValue += poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE;
						missingFullEpochs--;
					}

					// as _now was into the given era, we can stop the current loop here
					i = eraInfos.length;
				}
				// if it is in a different era then proceed using the eraEndingTime to compute the number of epochs left to
				// include in the current era and then proceed with the next value
				else {
					// NOTE: here some epochs may get lost as lastUpdateTime will almost never be equal to the exact epoch
					// 		update time, in order to avoid this error we compute the difference from the lastUpdateTime
					//		and the difference from the start of this era, as the two value will differ most of the times
					//		we compute the real number of epoch from the last fully completed one
					uint256 diffSinceEraEnd = eraEndingTime - lastUpdateTime;
					uint256 epochsSinceEraEnd = diffSinceEraEnd / _EPOCH_DURATION;

					uint256 diffSinceEraStart = eraEndingTime - eraInfos[i].startingTime;
					uint256 epochsSinceEraStart = diffSinceEraStart / _EPOCH_DURATION;

					uint256 missingFullEpochs = epochsSinceEraEnd;

					if(epochsSinceEraStart > epochsSinceEraEnd) {
						missingFullEpochs = epochsSinceEraStart - epochsSinceEraEnd;
					}

					// recompute the receipt value missingFullEpochs times
					while(missingFullEpochs > 0) {
						poolInfo.receiptValue += poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE;
						missingFullEpochs--;
					}
				}
			}
		}

		// No valid era exists this mean that the following era data were not generated yet, simply trigger the generation of the
		// next 2 eras and recall this method
		if(!validEraFound) {
			// in order to avoid the triggering of the error check at the begin of this method here we reduce the last receipt time by 1
			// this is an easy hack around the error check
			poolInfo.lastReceiptUpdateTime--;

			_triggerErasInfoRefresh(2);
			refreshReceiptValue();
		}

		emit ReceiptValueUpdate(poolInfo.receiptValue);
	}

	/**
		Retrieve the current era index in the eraInfos array

		@return Index of the current era
	 */
	function getCurrentEraIndex() public view returns(uint256) {
		uint256 _now = block.timestamp;
		uint256 eraEndingTime;
		for(uint256 i; i < eraInfos.length; i++) {
			eraEndingTime = eraInfos[i].startingTime + eraInfos[i].eraDuration;
			if(eraInfos[i].startingTime <= _now && _now <= eraEndingTime) {
				return i;
			}
		}
		return 0;
	}

	/**
		Returns the ordinal number of the current era

		@return Number of era passed
	 */
	function getCurrentEra() public view returns(uint256) {
		return getCurrentEraIndex() + 1;
	}

	/**
		Returns the number of epoch passed from the start of the pool

		@return Number or epoch passed
	 */
	function getEpochPassed() public view returns(uint256) {
		uint256 _now = block.timestamp;
		uint256 lastUpdateTime = poolInfo.lastReceiptUpdateTime;
		uint256 currentEra = getCurrentEraIndex();
		uint256 passedEpoch;
		uint256 eraEndingTime;

		// loop through previous eras
		for(uint256 i; i < currentEra; i++) {
			eraEndingTime = eraInfos[i].startingTime + eraInfos[i].eraDuration;
			passedEpoch += (eraInfos[i].startingTime - eraEndingTime) / _EPOCH_DURATION;
		}

		uint256 diffSinceLastUpdate = _now - lastUpdateTime;
		uint256 epochsSinceLastUpdate = diffSinceLastUpdate / _EPOCH_DURATION;

		uint256 diffSinceEraStart = _now - eraInfos[currentEra].startingTime;
		uint256 epochsSinceEraStart = diffSinceEraStart / _EPOCH_DURATION;

		uint256 missingFullEpochs = epochsSinceLastUpdate;

		if(epochsSinceEraStart > epochsSinceLastUpdate) {
			missingFullEpochs = epochsSinceEraStart - epochsSinceLastUpdate;
		}

		return passedEpoch + missingFullEpochs;
	}

	/**
		Increase the reward pool of this contract of _amount.
		Funds gets withdrawn from the caller address

		@param _amount MELD to insert into the reward pool
	 */
	function increaseRewardPool(uint256 _amount) public onlyOwner nonReentrant {
		prng.rotate();

		require(_amount > 0, "Unable to deposit null amount");
		require(melodity.balanceOf(msg.sender) >= _amount, "Not enough balance to stake");
		require(melodity.allowance(msg.sender, address(this)) >= _amount, "Allowance too low");

		melodity.transferFrom(msg.sender, address(this), _amount);
		poolInfo.rewardPool += _amount;

		_checkIfExhausting();
		emit RewardPoolIncreased(_amount);
	}

	/**
		Trigger the refresh of _eraAmount era infos

		@param _eraAmount Number of eras to refresh
	 */
	function refreshErasInfo(uint8 _eraAmount) public onlyOwner nonReentrant {
		prng.rotate();
		
		_triggerErasInfoRefresh(_eraAmount);
	}

	/**
		Update the reward scaling factor

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%

		@param _factor Percentage of the reward scaling factor
		@param _erasToRefresh Number of eras to refresh immediately starting from the next one
	 */
	function updateRewardScaleFactor(uint256 _factor, uint8 _erasToRefresh) public onlyOwner nonReentrant {
		prng.rotate();

		uint256 eraIndex = getCurrentEraIndex();
		EraInfo storage eraInfo = eraInfos[eraIndex];
		uint256 old = eraInfo.rewardScaleFactor;
		eraInfo.rewardScaleFactor = _factor;
		_triggerErasInfoRefresh(_erasToRefresh);
		emit RewardScalingFactorUpdate(old, eraInfo.rewardScaleFactor);
	}

	/**
		Update the era scaling factor

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%

		@param _factor Percentage of the era scaling factor
		@param _erasToRefresh Number of eras to refresh immediately starting from the next one
	 */
	function updateEraScaleFactor(uint256 _factor, uint8 _erasToRefresh) public onlyOwner nonReentrant {
		prng.rotate();

		uint256 eraIndex = getCurrentEraIndex();
		EraInfo storage eraInfo = eraInfos[eraIndex];
		uint256 old = eraInfo.eraScaleFactor;
		eraInfo.eraScaleFactor = _factor;
		_triggerErasInfoRefresh(_erasToRefresh);
		emit EraScalingFactorUpdate(old, eraInfo.eraScaleFactor);
	}
	
	/**
		Update the fee percentage applied to users withdrawing funds earlier

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%
		@notice The factor must be a value between feeInfo.minFeePercentage and feeInfo.maxFeePercentage

		@param _percent Percentage of the fee
	 */
	function updateEarlyWithdrawFeePercent(uint256 _percent) public onlyOwner nonReentrant {
		prng.rotate();
		
		require(_percent >= feeInfo.minFeePercentage, "Early withdraw fee too low");
		require(_percent <= feeInfo.maxFeePercentage, "Early withdraw fee too high");

		uint256 old = feeInfo.feePercentage;
		feeInfo.feePercentage = _percent;
		emit EarlyWithdrawFeeUpdate(old, feeInfo.feePercentage);
	}

	/**
		Update the fee receiver (where all dao's fee are sent)

		@notice This address should always be the dao's address

		@param _dao Address of the fee receiver
	 */
	function updateFeeReceiverAddress(address _dao) public onlyOwner nonReentrant {
		prng.rotate();
		
		require(_dao != address(0), "Provided address is invalid");

		address old = feeInfo.feeReceiver;
		feeInfo.feeReceiver = _dao;
		emit FeeReceiverUpdate(old, feeInfo.feeReceiver);
	}

	/**
		Update the withdraw period that a deposit is considered to be early

		@notice The period must be a value between 1 and 7 days

		@param _period Number or days or hours of the fee period
		@param _isDay Whether the provided period is in hours or in days
	 */
	function updateWithdrawFeePeriod(uint256 _period, bool _isDay) public onlyOwner nonReentrant {
		prng.rotate();
		
		if(_isDay) {
			// days (max 7 days, min 1 day)
			require(_period <= 7, "Withdraw period too long");
			require(_period >= 1, "Withdraw period too short");
			uint256 old = feeInfo.withdrawFeePeriod;
			uint256 day = 1 days;
			feeInfo.withdrawFeePeriod = _period * day;
			emit WithdrawPeriodUpdate(old, feeInfo.withdrawFeePeriod);
		}
		else {
			// hours (max 7 days, min 1 day)
			require(_period <= 168, "Withdraw period too long");
			require(_period >= 24, "Withdraw period too short");
			uint256 old = feeInfo.withdrawFeePeriod;
			uint256 hour = 1 hours;
			feeInfo.withdrawFeePeriod = _period * hour;
			emit WithdrawPeriodUpdate(old, feeInfo.withdrawFeePeriod);
		}
	}

	/**
		Update the share of the fee that is sent to the dao

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%
		@notice The percentage must be a value between feeInfo.feeReceiverMinPercent and 
				100 ether - feeInfo.feeMaintainerMinPercent

		@param _percent Percentage of the fee to send to the dao
	 */
	function updateDaoFeePercentage(uint256 _percent) public onlyOwner nonReentrant {
		prng.rotate();
		
		require(_percent >= feeInfo.feeReceiverMinPercent, "Dao's fee share too low");
		require(_percent <= 100 ether - feeInfo.feeMaintainerMinPercent, "Dao's fee share too high");

		uint256 old = feeInfo.feeReceiverPercentage;
		feeInfo.feeReceiverPercentage = _percent;
		feeInfo.feeMaintainerPercentage = 100 ether - _percent;
		emit DaoFeeSharedUpdate(old, feeInfo.feeReceiverPercentage);
		emit MaintainerFeeSharedUpdate(100 ether - old, feeInfo.feeMaintainerPercentage);
	}

	/**
		Update the fee percentage applied to users withdrawing funds earlier

		@notice The update factor is given as a percentage with high precision (18 decimal positions)
				Consider 100 ether = 100%
		@notice The percentage must be a value between feeInfo.feeMaintainerMinPercent and 
				100 ether - feeInfo.feeReceiverMinPercent

		@param _percent Percentage of the fee to send to the maintainers
	 */
	function updateMaintainerFeePercentage(uint256 _percent) public onlyOwner nonReentrant {
		prng.rotate();
		
		require(_percent >= feeInfo.feeMaintainerMinPercent, "Maintainer's fee share too low");
		require(_percent <= 100 ether - feeInfo.feeReceiverMinPercent, "Maintainer's fee share too high");

		uint256 old = feeInfo.feeMaintainerPercentage;
		feeInfo.feeMaintainerPercentage = _percent;
		feeInfo.feeReceiverPercentage = 100 ether - _percent;
		emit MaintainerFeeSharedUpdate(old, feeInfo.feeMaintainerPercentage);
		emit DaoFeeSharedUpdate(100 ether - old, feeInfo.feeReceiverPercentage);
	}

	/**
		Pause the stacking pool
	 */
	function pause() public whenNotPaused nonReentrant onlyOwner {
		prng.rotate();
		
		_pause();
	}

	/**
		Resume the stacking pool
	 */
	function resume() public whenPaused nonReentrant onlyOwner {
		prng.rotate();
		
		_unpause();
	}

	/**
		Allow dismission of the stacking pool once it is exhausting.
		The pool must be paused in order to lock the users from depositing but allow them to withdraw their funds.
		The dismission call can be launched only once all the stacking receipt gets reconverted back to MELD.

		@notice As evil users may want to leave their funds in the stacking pool to exhaust the pool balance 
				(even if practically impossible). The DAO can set the reward scaling factor to 0 actually stopping
				any reward for newer eras.
	 */
	function dismissionWithdraw() public whenPaused nonReentrant onlyOwner {
		prng.rotate();
		
		require(!poolInfo.dismissed, "Pool already dismissed");
		require(poolInfo.exhausting, "Dismission enabled only once the stacking pool is exhausting");
		require(stackingReceipt.totalSupply() == 0, "Unable to dismit the stacking pool as there are still circulating receipt");

		address addr;
		uint256 index;
		// refund all stacking pandas to their original owners if still locked in the pool
		for(uint8 i; i < 100; i++) {
			// if the depositor address is not the null address then the NFT is deposited into the pool
			addr = depositorNFT[i];
			if(addr != address(0)) {
				// reset index to zero if needed
				index = 0;

				// if more than one nft was stacked search the array for the one with the given id
				if(stackedNFTs[addr].length > 1) {
					for(; index < stackedNFTs[addr].length; index++) {
						// if the NFT identifier match exit the loop
						if(stackedNFTs[addr][index].nftId == i) {
							break;
						}
					}

					// swap the nft position with the last one
					stackedNFTs[addr][index] = stackedNFTs[addr][stackedNFTs[addr].length - 1];
					index = stackedNFTs[addr].length - 1;
				}

				// refund the NFT and reduce the size of the array
				stackingPanda.safeTransferFrom(address(this), addr, stackedNFTs[addr][index].nftId);
				stackedNFTs[addr].pop();
			}
		}

		// send all the remaining funds in the reward pool to the DAO
		melodity.transfer(feeInfo.feeReceiver, melodity.balanceOf(address(this)));

		// update the value at the end allowing this method to be called again if any error occurrs
		// the nonReentrant modifier anyway avoids any reentrancy attack
		poolInfo.dismissed = true;

		emit PoolDismissed();
	}
}


// File contracts/Masterchef.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;










contract Masterchef is ERC721Holder, ReentrancyGuard {
    StackingPanda public stackingPanda;
    PRNG public prng;
    Marketplace public marketplace;
	MelodityGovernance public melodityGovernanceToken;
	MelodityDAOTimelock public melodityDAOTimelock;
	MelodityDAO public melodityDAO;
	MelodityStacking public melodityStacking;
	StackingReceipt public melodityStackingReceipt;

    uint256 public mintingEpoch = 7 days;
    uint256 public lastMintingEvent;

    address public DoIncMultisigWallet =
        0x01Af10f1343C05855955418bb99302A6CF71aCB8;

    struct PandaIdentification {
        string name;
        string url;
    }

    PandaIdentification[] public pandas;

    event StackingPandaMinted(uint256 id);
    event StackingPandaForSale(address auction, uint256 id);

	/**
     * Network: Binance Smart Chain (BSC)     *
     * Melodity Bep20: 0x13E971De9181eeF7A4aEAEAA67552A6a4cc54f43

	 * Network: Binance Smart Chain TESTNET (BSC)     *
     * Melodity Bep20: 0x5EaA8Be0ebe73C0B6AdA8946f136B86b92128c55
     */
    constructor() {
		address melodity = 0x13E971De9181eeF7A4aEAEAA67552A6a4cc54f43;

        _deployPRNG();
        _deployStackingPandas();
        _deployMarketplace();
		_deployMelodityGovernance(melodity);
		_deployMelodityDAOTimelock();
		_deployMelodityDAO();
		_deployMelodityStacking(melodity);
    }

    /**
        Deploy stacking pandas NFT contract, deploying this contract let only the
        Masterchef itself mint new NFTs
     */
    function _deployStackingPandas() private {
        stackingPanda = StackingPanda(
            payable(
				Create2.deploy(
					0,
					keccak256("Masterchef/StackingPanda"),
					type(StackingPanda).creationCode
				)
			)
        );
        prng.rotate();
    }

    /**
        Deploy the Pseudo Random Number Generator using the create2 method,
        this gives the possibility for other generated smart contract to compute the
        PRNG address and call it
     */
    function _deployPRNG() private {
        prng = PRNG(
            payable(
				Create2.deploy(
					0,
					keccak256("Masterchef/PRNG"),
					type(PRNG).creationCode
				)
			)
        );
        prng.rotate();
    }

    /**
        Deploy the Marketplace using the create2 method,
        this gives the possibility for other generated smart contract to compute the
        PRNG address and call it
     */
    function _deployMarketplace() private {
        marketplace = Marketplace(
            payable(
				Create2.deploy(
					0,
					keccak256("Masterchef/Marketplace"),
					type(Marketplace).creationCode
				)
			)
        );
        prng.rotate();
    }

	function _deployMelodityGovernance(address _meld) private {
		melodityGovernanceToken = new MelodityGovernance(IERC20(_meld));
        prng.rotate();
	}

	function _deployMelodityDAOTimelock() private {
		address[] memory proposers = new address[](0);
		address[] memory executor = new address[](1);
		executor[0] = address(0);
		melodityDAOTimelock = new MelodityDAOTimelock(proposers, executor);
        prng.rotate();
	}

	function _deployMelodityDAO() private {
		melodityDAO = new MelodityDAO(melodityGovernanceToken, melodityDAOTimelock);
        prng.rotate();
	}

	function _deployMelodityStacking(address _meld) private {
		melodityStacking = new MelodityStacking(address(this), _meld, address(melodityDAOTimelock), 10);
        prng.rotate();

		melodityStackingReceipt = melodityStacking.stackingReceipt();
	}

    /**
        Trigger the minting of a new stacking panda, this function is publicly callable
        as the minted NFT will be given to the Masterchef contract.
     */
    function mintStackingPanda() public nonReentrant returns (address) {
        prng.rotate();

        // check that a new panda can be minted
        require(
            block.timestamp >= lastMintingEvent + mintingEpoch,
            "New pandas can be minted only once every 7 days"
        );

        // immediately update the last minting event in order to avoid reetracy
        lastMintingEvent = block.timestamp;

        // retrieve the random number and set the bonus percentage using 18 decimals.
        // NOTE: the maximum percentage here is 7.499999999999999999%
        uint256 meld2meldBonus = prng.rotate() % 7.5 ether;

        // retrieve the random number and set the bonus percentage using 18 decimals.
        // NOTE: the maximum percentage here is 3.999999999999999999%
        uint256 toMeldBonus = prng.rotate() % 4 ether;

        // mint the panda using its name-url from the stored pair and randomly compute the bonuses
        uint256 pandaId = stackingPanda.mint(
            "test",
            "url",
            StackingPanda.StackingBonus({
                decimals: 18,
                meldToMeld: meld2meldBonus,
                toMeld: toMeldBonus
            })
        );

        emit StackingPandaMinted(pandaId);

        return _listForSale(pandaId);
    }

    function _listForSale(uint256 _pandaId) private returns (address) {
        // approve the marketplace to create and start the auction
        stackingPanda.approve(address(marketplace), _pandaId);

        address auction = marketplace.createAuctionWithRoyalties(
            _pandaId,
            address(stackingPanda),
            // Melodity's multisig wallet address
            DoIncMultisigWallet,
            7 days,
            0.1 ether,
            1 ether,
            DoIncMultisigWallet,
            DoIncMultisigWallet
        );

        emit StackingPandaForSale(auction, _pandaId);
        return auction;
    }
}
