// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

//TESTING ONLY
contract TestWallet is Initializable {
    function initialize() external initializer {}

    function test() external {}

    function getTestSelector() external pure returns (bytes memory) {
        // return this.test.selector;
        bytes memory b = abi.encodeWithSelector(this.test.selector);
return b;
    }

    receive() external payable {}

    fallback() external {}
}
