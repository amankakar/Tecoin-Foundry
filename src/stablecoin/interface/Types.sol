
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
interface Types {
    struct StablecoinSwap {
        // recipient of the target currency
        address destination;
        // the originating currency
        address origin;
        // the amount of currency being provided
        uint256 oAmount;
        // the target currency
        address target;
        // the amount of currency to be provided
        uint256 tAmount;
    }


}