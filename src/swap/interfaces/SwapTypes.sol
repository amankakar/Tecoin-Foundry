
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ISimplePlugin.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface SwapTypes {
struct DefiSwap {
    // Address of the swap aggregator or router
    address aggregator;
    // Plugin for handling referral fees
    ISimplePlugin plugin;
    // Token collected as fees
    ERC20 feeToken;
    // Address to receive referral fees
    address referrer;
    // Amount of referral fee
    uint256 referralFee;
    // Data for wallet interaction, if any
    bytes walletData;
    // Data for performing the swap, if any
    bytes swapData;
}

}