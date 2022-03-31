// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../StackingPanda.sol";
import "../PRNG.sol";
import "./StackingReceipt.sol";

library console {
	event Log(bytes _type, bytes payload);

	function _sendLogPayload(bytes memory _type, bytes memory payload) private {
		emit Log(_type, payload);
	}

	function logInt(int p0) internal {
		_sendLogPayload(abi.encode("string", "int"), abi.encode("int", p0));
	}

	function logUint(uint p0) internal {
		_sendLogPayload(abi.encode("string", "uint"), abi.encode("uint", p0));
	}

	function logString(string memory p0) internal {
		_sendLogPayload(abi.encode("string", "string"), abi.encode("string", p0));
	}

	function logBool(bool p0) internal {
		_sendLogPayload(abi.encode("string", "bool"), abi.encode("bool", p0));
	}

	function logAddress(address p0) internal  {
		_sendLogPayload(abi.encode("string", "address"), abi.encode("address", p0));
	}

	function logBytes(bytes memory p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes"), abi.encode("bytes", p0));
	}

	function logBytes1(bytes1 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes1"), abi.encode("bytes1", p0));
	}

	function logBytes2(bytes2 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes2"), abi.encode("bytes2", p0));
	}

	function logBytes3(bytes3 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes3"), abi.encode("bytes3", p0));
	}

	function logBytes4(bytes4 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes4"), abi.encode("bytes4", p0));
	}

	function logBytes5(bytes5 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes5"), abi.encode("bytes5", p0));
	}

	function logBytes6(bytes6 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes6"), abi.encode("bytes6", p0));
	}

	function logBytes7(bytes7 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes7"), abi.encode("bytes7", p0));
	}

	function logBytes8(bytes8 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes8"), abi.encode("bytes8", p0));
	}

	function logBytes9(bytes9 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes9"), abi.encode("bytes9", p0));
	}

	function logBytes10(bytes10 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes10"), abi.encode("bytes10", p0));
	}

	function logBytes11(bytes11 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes11"), abi.encode("bytes11", p0));
	}

	function logBytes12(bytes12 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes12"), abi.encode("bytes12", p0));
	}

	function logBytes13(bytes13 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes13"), abi.encode("bytes13", p0));
	}

	function logBytes14(bytes14 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes14"), abi.encode("bytes14", p0));
	}

	function logBytes15(bytes15 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes15"), abi.encode("bytes15", p0));
	}

	function logBytes16(bytes16 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes16"), abi.encode("bytes16", p0));
	}

	function logBytes17(bytes17 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes17"), abi.encode("bytes17", p0));
	}

	function logBytes18(bytes18 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes18"), abi.encode("bytes18", p0));
	}

	function logBytes19(bytes19 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes19"), abi.encode("bytes19", p0));
	}

	function logBytes20(bytes20 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes20"), abi.encode("bytes20", p0));
	}

	function logBytes21(bytes21 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes21"), abi.encode("bytes21", p0));
	}

	function logBytes22(bytes22 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes22"), abi.encode("bytes22", p0));
	}

	function logBytes23(bytes23 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes23"), abi.encode("bytes23", p0));
	}

	function logBytes24(bytes24 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes24"), abi.encode("bytes24", p0));
	}

	function logBytes25(bytes25 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes25"), abi.encode("bytes25", p0));
	}

	function logBytes26(bytes26 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes26"), abi.encode("bytes26", p0));
	}

	function logBytes27(bytes27 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes27"), abi.encode("bytes27", p0));
	}

	function logBytes28(bytes28 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes28"), abi.encode("bytes28", p0));
	}

	function logBytes29(bytes29 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes29"), abi.encode("bytes29", p0));
	}

	function logBytes30(bytes30 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes30"), abi.encode("bytes30", p0));
	}

	function logBytes31(bytes31 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes31"), abi.encode("bytes31", p0));
	}

	function logBytes32(bytes32 p0) internal  {
		_sendLogPayload(abi.encode("string", "bytes32"), abi.encode("bytes32", p0));
	}

	function log(uint p0) internal  {
		_sendLogPayload(abi.encode("string", "uint"), abi.encode("uint", p0));
	}

	function log(string memory p0) internal  {
		_sendLogPayload(abi.encode("string", "string"), abi.encode("string", p0));
	}

	function log(bool p0) internal  {
		_sendLogPayload(abi.encode("string", "bool"), abi.encode("bool", p0));
	}

	function log(address p0) internal  {
		_sendLogPayload(abi.encode("string", "address"), abi.encode("address", p0));
	}

	function log(uint p0, uint p1) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint"), abi.encode("uint,uint", p0, p1));
	}

	function log(uint p0, string memory p1) internal  {
		_sendLogPayload(abi.encode("string", "uint,string"), abi.encode("uint,string", p0, p1));
	}

	function log(uint p0, bool p1) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool"), abi.encode("uint,bool", p0, p1));
	}

	function log(uint p0, address p1) internal  {
		_sendLogPayload(abi.encode("string", "uint,address"), abi.encode("uint,address", p0, p1));
	}

	function log(string memory p0, uint p1) internal  {
		_sendLogPayload(abi.encode("string", "string,uint"), abi.encode("string,uint", p0, p1));
	}

	function log(string memory p0, string memory p1) internal  {
		_sendLogPayload(abi.encode("string", "string,string"), abi.encode("string,string", p0, p1));
	}

	function log(string memory p0, bool p1) internal  {
		_sendLogPayload(abi.encode("string", "string,bool"), abi.encode("string,bool", p0, p1));
	}

	function log(string memory p0, address p1) internal  {
		_sendLogPayload(abi.encode("string", "string,address"), abi.encode("string,address", p0, p1));
	}

	function log(bool p0, uint p1) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint"), abi.encode("bool,uint", p0, p1));
	}

	function log(bool p0, string memory p1) internal  {
		_sendLogPayload(abi.encode("string", "bool,string"), abi.encode("bool,string", p0, p1));
	}

	function log(bool p0, bool p1) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool"), abi.encode("bool,bool", p0, p1));
	}

	function log(bool p0, address p1) internal  {
		_sendLogPayload(abi.encode("string", "bool,address"), abi.encode("bool,address", p0, p1));
	}

	function log(address p0, uint p1) internal  {
		_sendLogPayload(abi.encode("string", "address,uint"), abi.encode("address,uint", p0, p1));
	}

	function log(address p0, string memory p1) internal  {
		_sendLogPayload(abi.encode("string", "address,string"), abi.encode("address,string", p0, p1));
	}

	function log(address p0, bool p1) internal  {
		_sendLogPayload(abi.encode("string", "address,bool"), abi.encode("address,bool", p0, p1));
	}

	function log(address p0, address p1) internal  {
		_sendLogPayload(abi.encode("string", "address,address"), abi.encode("address,address", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,uint"), abi.encode("uint,uint,uint", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,string"), abi.encode("uint,uint,string", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,bool"), abi.encode("uint,uint,bool", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,address"), abi.encode("uint,uint,address", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,uint"), abi.encode("uint,string,uint", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,string"), abi.encode("uint,string,string", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,bool"), abi.encode("uint,string,bool", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,address"), abi.encode("uint,string,address", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,uint"), abi.encode("uint,bool,uint", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,string"), abi.encode("uint,bool,string", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,bool"), abi.encode("uint,bool,bool", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,address"), abi.encode("uint,bool,address", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,uint"), abi.encode("uint,address,uint", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,string"), abi.encode("uint,address,string", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,bool"), abi.encode("uint,address,bool", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,address"), abi.encode("uint,address,address", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,uint"), abi.encode("string,uint,uint", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,string"), abi.encode("string,uint,string", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,bool"), abi.encode("string,uint,bool", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,address"), abi.encode("string,uint,address", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "string,string,uint"), abi.encode("string,string,uint", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "string,string,string"), abi.encode("string,string,string", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "string,string,bool"), abi.encode("string,string,bool", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "string,string,address"), abi.encode("string,string,address", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,uint"), abi.encode("string,bool,uint", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,string"), abi.encode("string,bool,string", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,bool"), abi.encode("string,bool,bool", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,address"), abi.encode("string,bool,address", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "string,address,uint"), abi.encode("string,address,uint", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "string,address,string"), abi.encode("string,address,string", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "string,address,bool"), abi.encode("string,address,bool", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "string,address,address"), abi.encode("string,address,address", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,uint"), abi.encode("bool,uint,uint", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,string"), abi.encode("bool,uint,string", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,bool"), abi.encode("bool,uint,bool", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,address"), abi.encode("bool,uint,address", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,uint"), abi.encode("bool,string,uint", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,string"), abi.encode("bool,string,string", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,bool"), abi.encode("bool,string,bool", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,address"), abi.encode("bool,string,address", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,uint"), abi.encode("bool,bool,uint", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,string"), abi.encode("bool,bool,string", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,bool"), abi.encode("bool,bool,bool", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,address"), abi.encode("bool,bool,address", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,uint"), abi.encode("bool,address,uint", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,string"), abi.encode("bool,address,string", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,bool"), abi.encode("bool,address,bool", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,address"), abi.encode("bool,address,address", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,uint"), abi.encode("address,uint,uint", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,string"), abi.encode("address,uint,string", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,bool"), abi.encode("address,uint,bool", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,address"), abi.encode("address,uint,address", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "address,string,uint"), abi.encode("address,string,uint", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "address,string,string"), abi.encode("address,string,string", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "address,string,bool"), abi.encode("address,string,bool", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "address,string,address"), abi.encode("address,string,address", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,uint"), abi.encode("address,bool,uint", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,string"), abi.encode("address,bool,string", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,bool"), abi.encode("address,bool,bool", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,address"), abi.encode("address,bool,address", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal  {
		_sendLogPayload(abi.encode("string", "address,address,uint"), abi.encode("address,address,uint", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal  {
		_sendLogPayload(abi.encode("string", "address,address,string"), abi.encode("address,address,string", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal  {
		_sendLogPayload(abi.encode("string", "address,address,bool"), abi.encode("address,address,bool", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal  {
		_sendLogPayload(abi.encode("string", "address,address,address"), abi.encode("address,address,address", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,uint,uint"), abi.encode("uint,uint,uint,uint", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,uint,string"), abi.encode("uint,uint,uint,string", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,uint,bool"), abi.encode("uint,uint,uint,bool", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,uint,address"), abi.encode("uint,uint,uint,address", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,string,uint"), abi.encode("uint,uint,string,uint", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,string,string"), abi.encode("uint,uint,string,string", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,string,bool"), abi.encode("uint,uint,string,bool", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,string,address"), abi.encode("uint,uint,string,address", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,bool,uint"), abi.encode("uint,uint,bool,uint", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,bool,string"), abi.encode("uint,uint,bool,string", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,bool,bool"), abi.encode("uint,uint,bool,bool", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,bool,address"), abi.encode("uint,uint,bool,address", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,address,uint"), abi.encode("uint,uint,address,uint", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,address,string"), abi.encode("uint,uint,address,string", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,address,bool"), abi.encode("uint,uint,address,bool", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,uint,address,address"), abi.encode("uint,uint,address,address", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,uint,uint"), abi.encode("uint,string,uint,uint", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,uint,string"), abi.encode("uint,string,uint,string", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,uint,bool"), abi.encode("uint,string,uint,bool", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,uint,address"), abi.encode("uint,string,uint,address", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,string,uint"), abi.encode("uint,string,string,uint", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,string,string"), abi.encode("uint,string,string,string", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,string,bool"), abi.encode("uint,string,string,bool", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,string,address"), abi.encode("uint,string,string,address", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,bool,uint"), abi.encode("uint,string,bool,uint", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,bool,string"), abi.encode("uint,string,bool,string", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,bool,bool"), abi.encode("uint,string,bool,bool", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,bool,address"), abi.encode("uint,string,bool,address", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,address,uint"), abi.encode("uint,string,address,uint", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,address,string"), abi.encode("uint,string,address,string", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,address,bool"), abi.encode("uint,string,address,bool", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,string,address,address"), abi.encode("uint,string,address,address", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,uint,uint"), abi.encode("uint,bool,uint,uint", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,uint,string"), abi.encode("uint,bool,uint,string", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,uint,bool"), abi.encode("uint,bool,uint,bool", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,uint,address"), abi.encode("uint,bool,uint,address", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,string,uint"), abi.encode("uint,bool,string,uint", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,string,string"), abi.encode("uint,bool,string,string", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,string,bool"), abi.encode("uint,bool,string,bool", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,string,address"), abi.encode("uint,bool,string,address", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,bool,uint"), abi.encode("uint,bool,bool,uint", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,bool,string"), abi.encode("uint,bool,bool,string", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,bool,bool"), abi.encode("uint,bool,bool,bool", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,bool,address"), abi.encode("uint,bool,bool,address", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,address,uint"), abi.encode("uint,bool,address,uint", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,address,string"), abi.encode("uint,bool,address,string", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,address,bool"), abi.encode("uint,bool,address,bool", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,bool,address,address"), abi.encode("uint,bool,address,address", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,uint,uint"), abi.encode("uint,address,uint,uint", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,uint,string"), abi.encode("uint,address,uint,string", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,uint,bool"), abi.encode("uint,address,uint,bool", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,uint,address"), abi.encode("uint,address,uint,address", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,string,uint"), abi.encode("uint,address,string,uint", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,string,string"), abi.encode("uint,address,string,string", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,string,bool"), abi.encode("uint,address,string,bool", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,string,address"), abi.encode("uint,address,string,address", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,bool,uint"), abi.encode("uint,address,bool,uint", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,bool,string"), abi.encode("uint,address,bool,string", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,bool,bool"), abi.encode("uint,address,bool,bool", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,bool,address"), abi.encode("uint,address,bool,address", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,address,uint"), abi.encode("uint,address,address,uint", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,address,string"), abi.encode("uint,address,address,string", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,address,bool"), abi.encode("uint,address,address,bool", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "uint,address,address,address"), abi.encode("uint,address,address,address", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,uint,uint"), abi.encode("string,uint,uint,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,uint,string"), abi.encode("string,uint,uint,string", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,uint,bool"), abi.encode("string,uint,uint,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,uint,address"), abi.encode("string,uint,uint,address", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,string,uint"), abi.encode("string,uint,string,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,string,string"), abi.encode("string,uint,string,string", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,string,bool"), abi.encode("string,uint,string,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,string,address"), abi.encode("string,uint,string,address", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,bool,uint"), abi.encode("string,uint,bool,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,bool,string"), abi.encode("string,uint,bool,string", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,bool,bool"), abi.encode("string,uint,bool,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,bool,address"), abi.encode("string,uint,bool,address", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,address,uint"), abi.encode("string,uint,address,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,address,string"), abi.encode("string,uint,address,string", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,address,bool"), abi.encode("string,uint,address,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,uint,address,address"), abi.encode("string,uint,address,address", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,uint,uint"), abi.encode("string,string,uint,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,uint,string"), abi.encode("string,string,uint,string", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,uint,bool"), abi.encode("string,string,uint,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,uint,address"), abi.encode("string,string,uint,address", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,string,uint"), abi.encode("string,string,string,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,string,string"), abi.encode("string,string,string,string", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,string,bool"), abi.encode("string,string,string,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,string,address"), abi.encode("string,string,string,address", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,bool,uint"), abi.encode("string,string,bool,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,bool,string"), abi.encode("string,string,bool,string", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,bool,bool"), abi.encode("string,string,bool,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,bool,address"), abi.encode("string,string,bool,address", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,address,uint"), abi.encode("string,string,address,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,address,string"), abi.encode("string,string,address,string", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,address,bool"), abi.encode("string,string,address,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,string,address,address"), abi.encode("string,string,address,address", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,uint,uint"), abi.encode("string,bool,uint,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,uint,string"), abi.encode("string,bool,uint,string", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,uint,bool"), abi.encode("string,bool,uint,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,uint,address"), abi.encode("string,bool,uint,address", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,string,uint"), abi.encode("string,bool,string,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,string,string"), abi.encode("string,bool,string,string", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,string,bool"), abi.encode("string,bool,string,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,string,address"), abi.encode("string,bool,string,address", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,bool,uint"), abi.encode("string,bool,bool,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,bool,string"), abi.encode("string,bool,bool,string", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,bool,bool"), abi.encode("string,bool,bool,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,bool,address"), abi.encode("string,bool,bool,address", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,address,uint"), abi.encode("string,bool,address,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,address,string"), abi.encode("string,bool,address,string", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,address,bool"), abi.encode("string,bool,address,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,bool,address,address"), abi.encode("string,bool,address,address", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,uint,uint"), abi.encode("string,address,uint,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,uint,string"), abi.encode("string,address,uint,string", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,uint,bool"), abi.encode("string,address,uint,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,uint,address"), abi.encode("string,address,uint,address", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,string,uint"), abi.encode("string,address,string,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,string,string"), abi.encode("string,address,string,string", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,string,bool"), abi.encode("string,address,string,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,string,address"), abi.encode("string,address,string,address", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,bool,uint"), abi.encode("string,address,bool,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,bool,string"), abi.encode("string,address,bool,string", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,bool,bool"), abi.encode("string,address,bool,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,bool,address"), abi.encode("string,address,bool,address", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,address,uint"), abi.encode("string,address,address,uint", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,address,string"), abi.encode("string,address,address,string", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,address,bool"), abi.encode("string,address,address,bool", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "string,address,address,address"), abi.encode("string,address,address,address", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,uint,uint"), abi.encode("bool,uint,uint,uint", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,uint,string"), abi.encode("bool,uint,uint,string", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,uint,bool"), abi.encode("bool,uint,uint,bool", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,uint,address"), abi.encode("bool,uint,uint,address", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,string,uint"), abi.encode("bool,uint,string,uint", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,string,string"), abi.encode("bool,uint,string,string", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,string,bool"), abi.encode("bool,uint,string,bool", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,string,address"), abi.encode("bool,uint,string,address", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,bool,uint"), abi.encode("bool,uint,bool,uint", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,bool,string"), abi.encode("bool,uint,bool,string", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,bool,bool"), abi.encode("bool,uint,bool,bool", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,bool,address"), abi.encode("bool,uint,bool,address", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,address,uint"), abi.encode("bool,uint,address,uint", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,address,string"), abi.encode("bool,uint,address,string", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,address,bool"), abi.encode("bool,uint,address,bool", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,uint,address,address"), abi.encode("bool,uint,address,address", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,uint,uint"), abi.encode("bool,string,uint,uint", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,uint,string"), abi.encode("bool,string,uint,string", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,uint,bool"), abi.encode("bool,string,uint,bool", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,uint,address"), abi.encode("bool,string,uint,address", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,string,uint"), abi.encode("bool,string,string,uint", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,string,string"), abi.encode("bool,string,string,string", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,string,bool"), abi.encode("bool,string,string,bool", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,string,address"), abi.encode("bool,string,string,address", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,bool,uint"), abi.encode("bool,string,bool,uint", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,bool,string"), abi.encode("bool,string,bool,string", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,bool,bool"), abi.encode("bool,string,bool,bool", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,bool,address"), abi.encode("bool,string,bool,address", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,address,uint"), abi.encode("bool,string,address,uint", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,address,string"), abi.encode("bool,string,address,string", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,address,bool"), abi.encode("bool,string,address,bool", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,string,address,address"), abi.encode("bool,string,address,address", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,uint,uint"), abi.encode("bool,bool,uint,uint", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,uint,string"), abi.encode("bool,bool,uint,string", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,uint,bool"), abi.encode("bool,bool,uint,bool", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,uint,address"), abi.encode("bool,bool,uint,address", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,string,uint"), abi.encode("bool,bool,string,uint", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,string,string"), abi.encode("bool,bool,string,string", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,string,bool"), abi.encode("bool,bool,string,bool", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,string,address"), abi.encode("bool,bool,string,address", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,bool,uint"), abi.encode("bool,bool,bool,uint", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,bool,string"), abi.encode("bool,bool,bool,string", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,bool,bool"), abi.encode("bool,bool,bool,bool", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,bool,address"), abi.encode("bool,bool,bool,address", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,address,uint"), abi.encode("bool,bool,address,uint", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,address,string"), abi.encode("bool,bool,address,string", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,address,bool"), abi.encode("bool,bool,address,bool", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,bool,address,address"), abi.encode("bool,bool,address,address", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,uint,uint"), abi.encode("bool,address,uint,uint", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,uint,string"), abi.encode("bool,address,uint,string", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,uint,bool"), abi.encode("bool,address,uint,bool", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,uint,address"), abi.encode("bool,address,uint,address", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,string,uint"), abi.encode("bool,address,string,uint", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,string,string"), abi.encode("bool,address,string,string", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,string,bool"), abi.encode("bool,address,string,bool", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,string,address"), abi.encode("bool,address,string,address", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,bool,uint"), abi.encode("bool,address,bool,uint", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,bool,string"), abi.encode("bool,address,bool,string", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,bool,bool"), abi.encode("bool,address,bool,bool", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,bool,address"), abi.encode("bool,address,bool,address", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,address,uint"), abi.encode("bool,address,address,uint", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,address,string"), abi.encode("bool,address,address,string", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,address,bool"), abi.encode("bool,address,address,bool", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "bool,address,address,address"), abi.encode("bool,address,address,address", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,uint,uint"), abi.encode("address,uint,uint,uint", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,uint,string"), abi.encode("address,uint,uint,string", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,uint,bool"), abi.encode("address,uint,uint,bool", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,uint,address"), abi.encode("address,uint,uint,address", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,string,uint"), abi.encode("address,uint,string,uint", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,string,string"), abi.encode("address,uint,string,string", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,string,bool"), abi.encode("address,uint,string,bool", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,string,address"), abi.encode("address,uint,string,address", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,bool,uint"), abi.encode("address,uint,bool,uint", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,bool,string"), abi.encode("address,uint,bool,string", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,bool,bool"), abi.encode("address,uint,bool,bool", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,bool,address"), abi.encode("address,uint,bool,address", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,address,uint"), abi.encode("address,uint,address,uint", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,address,string"), abi.encode("address,uint,address,string", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,address,bool"), abi.encode("address,uint,address,bool", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,uint,address,address"), abi.encode("address,uint,address,address", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,uint,uint"), abi.encode("address,string,uint,uint", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,uint,string"), abi.encode("address,string,uint,string", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,uint,bool"), abi.encode("address,string,uint,bool", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,uint,address"), abi.encode("address,string,uint,address", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,string,uint"), abi.encode("address,string,string,uint", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,string,string"), abi.encode("address,string,string,string", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,string,bool"), abi.encode("address,string,string,bool", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,string,address"), abi.encode("address,string,string,address", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,bool,uint"), abi.encode("address,string,bool,uint", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,bool,string"), abi.encode("address,string,bool,string", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,bool,bool"), abi.encode("address,string,bool,bool", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,bool,address"), abi.encode("address,string,bool,address", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,address,uint"), abi.encode("address,string,address,uint", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,address,string"), abi.encode("address,string,address,string", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,address,bool"), abi.encode("address,string,address,bool", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,string,address,address"), abi.encode("address,string,address,address", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,uint,uint"), abi.encode("address,bool,uint,uint", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,uint,string"), abi.encode("address,bool,uint,string", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,uint,bool"), abi.encode("address,bool,uint,bool", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,uint,address"), abi.encode("address,bool,uint,address", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,string,uint"), abi.encode("address,bool,string,uint", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,string,string"), abi.encode("address,bool,string,string", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,string,bool"), abi.encode("address,bool,string,bool", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,string,address"), abi.encode("address,bool,string,address", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,bool,uint"), abi.encode("address,bool,bool,uint", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,bool,string"), abi.encode("address,bool,bool,string", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,bool,bool"), abi.encode("address,bool,bool,bool", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,bool,address"), abi.encode("address,bool,bool,address", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,address,uint"), abi.encode("address,bool,address,uint", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,address,string"), abi.encode("address,bool,address,string", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,address,bool"), abi.encode("address,bool,address,bool", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,bool,address,address"), abi.encode("address,bool,address,address", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,uint,uint"), abi.encode("address,address,uint,uint", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,uint,string"), abi.encode("address,address,uint,string", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,uint,bool"), abi.encode("address,address,uint,bool", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,uint,address"), abi.encode("address,address,uint,address", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,string,uint"), abi.encode("address,address,string,uint", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,string,string"), abi.encode("address,address,string,string", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,string,bool"), abi.encode("address,address,string,bool", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,string,address"), abi.encode("address,address,string,address", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,bool,uint"), abi.encode("address,address,bool,uint", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,bool,string"), abi.encode("address,address,bool,string", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,bool,bool"), abi.encode("address,address,bool,bool", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,bool,address"), abi.encode("address,address,bool,address", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,address,uint"), abi.encode("address,address,address,uint", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,address,string"), abi.encode("address,address,address,string", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,address,bool"), abi.encode("address,address,address,bool", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal  {
		_sendLogPayload(abi.encode("string", "address,address,address,address"), abi.encode("address,address,address,address", p0, p1, p2, p3));
	}

}

/**
	@author Emanuele (ebalo) Balsamo
	@custom:security-contact security@melodity.org
 */
contract MelodityStacking is ERC721Holder, Ownable, Pausable, ReentrancyGuard {
	address constant public _DO_INC_MULTISIG_WALLET = 0x01Af10f1343C05855955418bb99302A6CF71aCB8;
	uint256 constant public _PERCENTAGE_SCALE = 10 ** 20;
	uint256 constant public _EPOCH_DURATION = 1 hours;

	/// Max fee if withdraw occurr before withdrawFeePeriod days
	uint256 constant public _MAX_FEE_PERCENTAGE = 10 ether;
	/// Min fee if withdraw occurr before withdrawFeePeriod days
	uint256 constant public _MIN_FEE_PERCENTAGE = 0.1 ether;

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
		@param lastComputedEra Index of the last computed era in the eraInfos array
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
		uint256 lastComputedEra;
	}

	/**
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
	mapping(address => uint256) private stackersHigherDeposit;
	mapping(address => StackedNFT[]) public stackedNFTs;
	mapping(uint256 => address) public depositorNFT;

    ERC20 public melodity;
	StackingReceipt public stackingReceipt;
    PRNG public prng;
	StackingPanda public stackingPanda;

	event Deposit(address indexed account, uint256 amount, uint256 receiptAmount);
	event NFTDeposit(address indexed account, uint256 nftId, uint256 nftPositionIndex);
	event ReceiptValueUpdate(uint256 value);
	event Withdraw(address indexed account, uint256 amount, uint256 receiptAmount);
	event NFTWithdraw(address indexed account, uint256 nftId);
	event FeePaid(uint256 amount, uint256 receiptAmount);
	event RewardPoolIncreased(uint256 insertedAmount);
	event PoolExhausting(uint256 amountLeft);
	event PoolRefilled(uint256 amountLeft);
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

		@param _prng The masterchef generator contract address,
			it deploies other contracts
		@param _melodity Melodity ERC20 contract address
	 */
    constructor(address _prng, address _stackingPanda, address _melodity, address _dao, uint8 _erasToGenerate) {
		prng = PRNG(_prng);
		stackingPanda = StackingPanda(_stackingPanda);
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
			dismissed: false,
			lastComputedEra: 0
		});

		feeInfo = FeeInfo({
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

	function getNewEraInfo(uint256 k) private view returns(EraInfo memory) {
		// get the genesis value or the last one available.
		// NOTE: as this is a modification of existing values the last available value before
		// 		the curren one is stored as the (k-1)-th element of the eraInfos array
		uint256 lastTimestamp = k == 0 ? poolInfo.genesisTime : eraInfos[k - 1].startingTime + eraInfos[k - 1].eraDuration;
		uint256 lastEraDuration = k == 0 ? poolInfo.genesisEraDuration : eraInfos[k - 1].eraDuration;
		uint256 lastEraScalingFactor = k == 0 ? poolInfo.genesisEraScaleFactor : eraInfos[k - 1].eraScaleFactor;
		uint256 lastRewardScalingFactor = k == 0 ? poolInfo.genesisRewardScaleFactor : eraInfos[k - 1].rewardScaleFactor;
		uint256 lastEpochRewardFactor = k == 0 ? poolInfo.genesisRewardFactorPerEpoch : eraInfos[k - 1].rewardFactorPerEpoch;

		uint256 newEraDuration = k != 0 ? lastEraDuration * lastEraScalingFactor / _PERCENTAGE_SCALE : poolInfo.genesisEraDuration;

		return EraInfo({
			// new eras starts always the second after the ending of the previous
			// if era-1 ends at sec 1234 era-2 will start at sec 1235
			startingTime: lastTimestamp + 1,
			eraDuration: newEraDuration,
			rewardScaleFactor: lastRewardScalingFactor,
			eraScaleFactor: lastEraScalingFactor,
			rewardFactorPerEpoch: k != 0 ? lastEpochRewardFactor * lastRewardScalingFactor / _PERCENTAGE_SCALE : poolInfo.genesisRewardFactorPerEpoch
		});
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
		// 9
		uint256 existingEraInfoCount = eraInfos.length;
		uint256 i;
		uint256 k;

		// - 0: 0 < 1 ? true
		// - 1: 1 < 1 ? false
		while(i < _erasToGenerate) {
			// check if exists some era infos, if they exists check if the k-th era is already started
			// if it is already started it cannot be edited and we won't consider it actually increasing 
			// k
			// - 0: 9 > 0 ? true & 1646996113 < 1648269466 ? true => pass
			// - 0: 9 > 1 ? true & 1649588114 < 1648269466 ? false
			if(existingEraInfoCount > k && eraInfos[k].startingTime <= block.timestamp) {
				k++;
			}
			// if the era is not yet started we can modify its values
			// - 0: 9 > 1 ? true & 1649588114 > 1648269466 ? true => pass
			else if(existingEraInfoCount > k && eraInfos[k].startingTime > block.timestamp) {
				// - 0: k = 1 & {
					// 	startingTime: 1649588114,
					// 	eraDuration: 2047680,
					// 	rewardScaleFactor: 79000000000000000000,
					// 	eraScaleFactor: 107000000000000000000,
					// 	rewardFactorPerEpoch: 790000000000000
				// }
				eraInfos[k] = getNewEraInfo(k);

				// as an era was just updated increase the i counter
				i++;
				// in order to move to the next era or start creating a new one we also need to increase
				// k counter
				k++;
			}
			// start generating new eras info if the number of existing eras is equal to the last computed
			else if(existingEraInfoCount == k) {
				eraInfos.push(getNewEraInfo(k));

				// as an era was just created increase the i counter
				i++;
				// in order to move to the next era and start creating a new one we also need to increase
				// k counter and the existingErasInfos counter
				existingEraInfoCount = eraInfos.length;
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
		prng.seedRotate();

		require(_amount > 0, "Unable to deposit null amount");

		refreshReceiptValue();

		// transfer the funds from the sender to the stacking contract, the contract balance will
		// increase but the reward pool will not
		melodity.transferFrom(msg.sender, address(this), _amount);

		// weighted stake last time
		// NOTE: prev_date = 0 => balance = 0, equation reduces to block.timestamp
		uint256 prev_date = stackersLastDeposit[msg.sender];
		uint256 balance = stackingReceipt.balanceOf(msg.sender);
		stackersLastDeposit[msg.sender] = (balance + _amount) > 0 ?
			prev_date + (block.timestamp - prev_date) * (_amount / (balance + _amount)) :
			prev_date;

		// mint the stacking receipt to the depositor
		uint256 receiptAmount = _amount * 1 ether / poolInfo.receiptValue;
		stackingReceipt.mint(msg.sender, receiptAmount);

		emit Deposit(msg.sender, _amount, receiptAmount);

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
		prng.seedRotate();

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

		emit NFTDeposit(msg.sender, _nftId, stackedNFTs[msg.sender].length -1);
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
		prng.seedRotate();

        require(_amount > 0, "Nothing to withdraw");

		refreshReceiptValue();

		// burn the receipt from the sender address
        stackingReceipt.burnFrom(msg.sender, _amount);

		uint256 meldToWithdraw = _amount * poolInfo.receiptValue / 1 ether;

		// reduce the reward pool
		poolInfo.rewardPool -= meldToWithdraw - _amount;
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
		prng.seedRotate();
		
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
	function refreshReceiptValuePaginated(uint256 max_cicles) public {
		prng.seedRotate();

		uint256 _now = block.timestamp;
		console.log("_now", _now);
		uint256 lastUpdateTime = poolInfo.lastReceiptUpdateTime;
		console.log("lastUpdateTime", lastUpdateTime);
		require(lastUpdateTime < _now, "Receipt value already update in this transaction");

		poolInfo.lastReceiptUpdateTime = block.timestamp;
		console.log("poolInfo.lastReceiptUpdateTime", poolInfo.lastReceiptUpdateTime);

		uint256 eraEndingTime;
		bool validEraFound = true;
		uint256 length = eraInfos.length;
		console.log("eraEndingTime", eraEndingTime);
		console.log("validEraFound", validEraFound);
		console.log("length", length);

		// In case _now exceeds the last era info ending time validEraFound would be true this will avoid the creation
		// of new era infos leading to pool locking and price not updating anymore
		uint256 last_index = eraInfos.length - 1;
		uint256 last_era_ending_time = eraInfos[last_index].startingTime + eraInfos[last_index].eraDuration;
		if(_now > last_era_ending_time) {
			validEraFound = false;
		}
		console.log("last_index", last_index);
		console.log("last_era_ending_time", last_era_ending_time);
		console.log("validEraFound", validEraFound);

		// No valid era exists this mean that the following era data were not generated yet, 
		// estimate the number of required eras then generate them
		// always enters as the default value will always be false, at least an era will always be generated
		if(!validEraFound) {
			// estimate needed era infos and always add 1
			uint256 eras_to_generate = 1;
			console.log("eras_to_generate", eras_to_generate);
			while(_now > last_era_ending_time) {
				EraInfo memory ei = getNewEraInfo(last_index);
				last_era_ending_time = ei.startingTime + ei.eraDuration;
				console.log("last_era_ending_time", last_era_ending_time);
				last_index++;
				console.log("last_index", last_index);
			}
			eras_to_generate += last_index - eraInfos.length;
			console.log("eras_to_generate", eras_to_generate);
			
			// to check
			_triggerErasInfoRefresh(uint8(eras_to_generate));
		}

		// set a max cap of cicles to do, if the cap exceeds the eras computed than use length as max cap
		uint256 proposed_length = poolInfo.lastComputedEra + max_cicles;
		length = proposed_length > length ? length : proposed_length;
		console.log("proposed_length", proposed_length);
		console.log("length", length);

		console.log("poolInfo.lastComputedEra", poolInfo.lastComputedEra);
		for(uint256 i = poolInfo.lastComputedEra; i < length; i++) {
			console.log("i", i);
			eraEndingTime = eraInfos[i].startingTime + eraInfos[i].eraDuration;
			console.log("eraInfos[i].startingTime", eraInfos[i].startingTime);
			console.log("eraInfos[i].eraDuration", eraInfos[i].eraDuration);
			console.log("eraEndingTime", eraEndingTime);
			console.log("lastUpdateTime", lastUpdateTime);
			console.log("eraInfos[i].startingTime <= lastUpdateTime", eraInfos[i].startingTime <= lastUpdateTime);
			console.log("lastUpdateTime <= eraEndingTime", lastUpdateTime <= eraEndingTime);

			// check if the lastUpdateTime is inside the currently checking era
			if(eraInfos[i].startingTime <= lastUpdateTime && lastUpdateTime <= eraEndingTime) {
				console.log("first if branch entered with i = ", i);
				console.log("eraInfos[i].startingTime <= _now", eraInfos[i].startingTime <= _now);
				console.log("_now <= eraEndingTime", _now <= eraEndingTime);
				// check if _now is in the same era of the lastUpdateTime, if it is then use _now to recompute the receipt value
				if(eraInfos[i].startingTime <= _now && _now <= eraEndingTime) {
					// NOTE: here some epochs may get lost as lastUpdateTime will almost never be equal to the exact epoch
					// 		update time, in order to avoid this error we compute the difference from the lastUpdateTime
					//		and the difference from the start of this era, as the two value will differ most of the times
					//		we compute the real number of epoch from the last fully completed one

					console.log("entering if branch with i = ", i);
					uint256 diff = (_now - lastUpdateTime) / _EPOCH_DURATION;
					console.log("(_now - lastUpdateTime)", (_now - lastUpdateTime));
					console.log("_EPOCH_DURATION", _EPOCH_DURATION);
					console.log("diff", diff);
					// TODO: CHECK THE ABOVE FRAGMENT FOR ERROR DURING AUDIT FIX

					// recompute the receipt value missingFullEpochs times
					while(diff > 0) {
						console.log("poolInfo.receiptValue", poolInfo.receiptValue);
						console.log("eraInfos[i].rewardFactorPerEpoch", eraInfos[i].rewardFactorPerEpoch);
						console.log("_PERCENTAGE_SCALE", _PERCENTAGE_SCALE);
						console.log("poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch", poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch);
						console.log("poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE", poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE);
						poolInfo.receiptValue += poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE;
						
						console.log("poolInfo.receiptValue", poolInfo.receiptValue);
						diff--;
						console.log("diff", diff);
					}
					// BUG: HERE DIFF IS ALWAYS 0
					poolInfo.lastReceiptUpdateTime = lastUpdateTime + diff * _EPOCH_DURATION;
					console.log("diff * _EPOCH_DURATION", diff * _EPOCH_DURATION);
					console.log("poolInfo.lastReceiptUpdateTime", poolInfo.lastReceiptUpdateTime);
					poolInfo.lastComputedEra = i;
					console.log("poolInfo.lastComputedEra", poolInfo.lastComputedEra);

					// as _now was into the given era, we can stop the current loop here
					break;
				}
				// if it is in a different era then proceed using the eraEndingTime to compute the number of epochs left to
				// include in the current era and then proceed with the next value
				else {
					// NOTE: here some epochs may get lost as lastUpdateTime will almost never be equal to the exact epoch
					// 		update time, in order to avoid this error we compute the difference from the lastUpdateTime
					//		and the difference from the start of this era, as the two value will differ most of the times
					//		we compute the real number of epoch from the last fully completed one
					console.log("entering else branch with i = ", i);
					console.log("_EPOCH_DURATION", _EPOCH_DURATION);
					console.log("eraEndingTime", eraEndingTime);
					uint256 diffFromEpochStartAlignment = _EPOCH_DURATION - (eraEndingTime % _EPOCH_DURATION);
					console.log("diffFromEpochStartAlignment", diffFromEpochStartAlignment);
					uint256 realEpochStartTime = eraEndingTime - diffFromEpochStartAlignment;
					console.log("realEpochStartTime", realEpochStartTime);
					uint256 diff = (eraEndingTime - lastUpdateTime) / _EPOCH_DURATION;
					console.log("lastUpdateTime", lastUpdateTime);
					console.log("diff", diff);

					// recompute the receipt value missingFullEpochs times
					while(diff > 0) {
						console.log("poolInfo.receiptValue", poolInfo.receiptValue);
						console.log("eraInfos[i].rewardFactorPerEpoch", eraInfos[i].rewardFactorPerEpoch);
						console.log("_PERCENTAGE_SCALE", _PERCENTAGE_SCALE);
						console.log("poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch", poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch);
						console.log("poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE", poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE);
						poolInfo.receiptValue += poolInfo.receiptValue * eraInfos[i].rewardFactorPerEpoch / _PERCENTAGE_SCALE;

						console.log("poolInfo.receiptValue", poolInfo.receiptValue);
						diff--;
						console.log("diff", diff);
					}
					console.log("realEpochStartTime", realEpochStartTime);
					poolInfo.lastReceiptUpdateTime = realEpochStartTime;
					console.log("poolInfo.lastReceiptUpdateTime", poolInfo.lastReceiptUpdateTime);
					poolInfo.lastComputedEra = i;
					console.log("poolInfo.lastComputedEra", poolInfo.lastComputedEra);

					// as accessing the next era info using index+1 can throw an index out of bound the
					// next era starting time is computed based on the curren era
					lastUpdateTime = eraInfos[i].startingTime + eraInfos[i].eraDuration + 1;
					console.log("eraInfos[i].startingTime", eraInfos[i].startingTime);
					console.log("eraInfos[i].eraDuration", eraInfos[i].eraDuration);
					console.log("lastUpdateTime", lastUpdateTime);
				}
			}
		}

		emit ReceiptValueUpdate(poolInfo.receiptValue);
	}

	/**
		Update the receipt value if necessary

		@notice This method *MUST* never be marked as nonReentrant as if no valid era was found it
				calls itself back after the generation of 2 new era infos
	 */
	function refreshReceiptValue() public {
		refreshReceiptValuePaginated(2);
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
		prng.seedRotate();

		require(_amount > 0, "Unable to deposit null amount");

		melodity.transferFrom(msg.sender, address(this), _amount);
		poolInfo.rewardPool += _amount;

		if(poolInfo.rewardPool >= 1_000_000 ether) {
			poolInfo.exhausting = false;
			emit PoolRefilled(poolInfo.rewardPool);
		}

		emit RewardPoolIncreased(_amount);
	}

	/**
		Trigger the refresh of _eraAmount era infos

		@param _eraAmount Number of eras to refresh
	 */
	function refreshErasInfo(uint8 _eraAmount) public onlyOwner nonReentrant {
		prng.seedRotate();
		
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
		prng.seedRotate();

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
		prng.seedRotate();

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
		prng.seedRotate();
		
		require(_percent >= _MIN_FEE_PERCENTAGE, "Early withdraw fee too low");
		require(_percent <= _MAX_FEE_PERCENTAGE, "Early withdraw fee too high");

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
		prng.seedRotate();
		
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
		prng.seedRotate();
		
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
		prng.seedRotate();
		
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
		prng.seedRotate();
		
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
		prng.seedRotate();
		
		_pause();
	}

	/**
		Resume the stacking pool
	 */
	function resume() public whenPaused nonReentrant onlyOwner {
		prng.seedRotate();
		
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
		prng.seedRotate();
		
		require(!poolInfo.dismissed, "Pool already dismissed");
		// disabled if dismission is required before exhaustion
		// require(poolInfo.exhausting, "Dismission enabled only once the stacking pool is exhausting");
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