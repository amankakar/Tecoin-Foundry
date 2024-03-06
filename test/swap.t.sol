// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {AmirX } from "../src/swap/AmirX.sol";
import {MockAmirX } from "../src/swap/test/MockAmirX.sol";

import {ISimplePlugin} from "../src/swap/interfaces/ISimplePlugin.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Types} from "../src/stablecoin/interface/Types.sol";
import {SwapTypes } from "../src/swap/interfaces/SwapTypes.sol";
import {TestWallet} from "../src/test/TestWallet.sol";
import {Stablecoin } from "../src/stablecoin/Stablecoin.sol";
import {TestPlugin} from "../src/swap/test/TestPlugin.sol";
// import {StablecoinSwap , eXYZ} from "../src/stablecoin/StablecoinHandler.sol";


contract MockERC20 is ERC20 {
    constructor()ERC20("TELCOIN" , "TEL"){

    }
    function mintTo(address user , uint256 amount ) public {
        _mint(user , amount);
    }
}
contract SwapTest is Types , SwapTypes,Test {

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT_ROLE");
    bytes32 public constant SWAPPER_ROLE = keccak256('SWAPPER_ROLE');
    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
    bytes32 public constant BURNER_ROLE = keccak256('BURNER_ROLE');
    bytes32 public constant MAINTAINER_ROLE = keccak256('MAINTAINER_ROLE');

    

    MockAmirX public amirx;

    // list of stable coins
    Stablecoin public eUSDC;
    Stablecoin public  eUSDT;
    Stablecoin public eUSDS; 

    MockERC20 Telcoin ;

    TestWallet wallet;

    TestPlugin testPlugin;

// users

address holder = address(0x23);
address receiver = address(0x12);

    struct eXYZ {
        // status of address as stablecoin
        bool validity;
        // the max mint limit
        uint256 maxSupply;
        // the min burn limit
        uint256 minSupply;
    }

function setUp() public{
    Telcoin = new MockERC20();
amirx = new MockAmirX((Telcoin));
amirx.initialize();

wallet = new TestWallet();

testPlugin = new TestPlugin(Telcoin);

amirx.grantRole(SWAPPER_ROLE, address(this));
amirx.grantRole(MAINTAINER_ROLE, address(this));
amirx.grantRole(BURNER_ROLE, address(this));

eUSDC = new Stablecoin();
eUSDC.initialize("US Dollar", "eXYZ", 6);

eUSDT = new Stablecoin();
eUSDT.initialize("US Dollar", "eXYZ", 18);


eUSDS = new Stablecoin();
eUSDS.initialize("US Dollar", "eXYZ", 18);

 eUSDC.grantRole(MINTER_ROLE, address(this));
 eUSDT.grantRole(MINTER_ROLE, address(this));

 eUSDC.grantRole(BURNER_ROLE, address(this));
 eUSDT.grantRole(BURNER_ROLE, address(this));

 eUSDC.grantRole(BURNER_ROLE, address(amirx));
 eUSDT.grantRole(BURNER_ROLE, address(amirx));
 eUSDS.grantRole(BURNER_ROLE, address(amirx));
 eUSDS.grantRole(BURNER_ROLE, address(this));


 eUSDC.grantRole(MINTER_ROLE, address(amirx));
 eUSDT.grantRole(MINTER_ROLE, address(amirx));
 eUSDS.grantRole(MINTER_ROLE, address(amirx));

 eUSDS.grantRole(MINTER_ROLE, address(this));



  amirx.UpdateXYZ(address(eUSDC), true, 1000000000, 0);

  amirx.UpdateXYZ(address(eUSDT), true, 1000000000, 0);


}
function testOwnerSet() public {
    assertEq(amirx.hasRole(DEFAULT_ADMIN_ROLE , address(this)) ,true );
}
function testSwapperRole() public {
    assertEq(amirx.hasRole(SWAPPER_ROLE , address(this)) ,true );
}


function testSwapfff() public {
     eUSDC.mintTo(holder, 10);

     StablecoinSwap memory stableInputs =  StablecoinSwap({
        destination: holder,
        origin: address(eUSDC),
        oAmount: 10,
        target: address(eUSDT),
        tAmount: 100
    });


    DefiSwap memory defiSwap = DefiSwap({
        aggregator: address(this),
        plugin: ISimplePlugin(address(0)),
        feeToken:  ERC20(address(eUSDT)),
        referrer: address(0),
        referralFee: 2,
        walletData: '0x',//await wallet.getTestSelector(),
        swapData: '0x'
    });
    vm.prank(address(holder));
     eUSDC.approve(address(amirx), 10);
     amirx.stablecoinSwap(address(holder), address(receiver), stableInputs, defiSwap);

    assertEq(eUSDT.balanceOf(holder) , 100);
    assertEq(eUSDC.balanceOf(holder) , 0);

    assertEq(eUSDT.balanceOf(receiver) , 0);
    assertEq(eUSDC.balanceOf(receiver) , 0);
    assertEq(ERC20(address(eUSDT)).balanceOf(address(this)), 0);

}


function testStableSwap() public {
    eUSDC.mintTo(holder, 10);
    eUSDS.mintTo(receiver, 100);

    StablecoinSwap memory stableInputs =  StablecoinSwap({
       destination: holder,
       origin: address(eUSDC),
       oAmount: 10,
       target: address(eUSDS),
       tAmount: 100
   });


   DefiSwap memory defiSwap = DefiSwap({
       aggregator: address(this),
       plugin: ISimplePlugin(address(testPlugin)),
       feeToken:  ERC20(address(eUSDT)),
       referrer: address(receiver),
       referralFee: 2,
       walletData:  bytes(wallet.getTestSelector()),
       swapData: bytes(wallet.getTestSelector())
   });
   vm.startPrank(address(holder));
   Telcoin.mintTo(receiver, 10);

    eUSDC.approve(address(amirx), 10);
    eUSDS.approve(address(amirx), 100);
    Telcoin.approve(address(amirx) , 2);

    eUSDS.approve(address(this), 100);

   vm.stopPrank();
   Telcoin.mintTo(receiver, 10);

   vm.startPrank(address(receiver));
   eUSDS.approve(address(amirx), 100);
   Telcoin.approve(address(amirx) , 2);

   vm.stopPrank();

    amirx.stablecoinSwap(address(holder), address(receiver), stableInputs, defiSwap);

   assertEq(eUSDS.balanceOf(holder) , 100);
   assertEq(eUSDS.balanceOf(receiver) , 0);

   assertEq(Telcoin.balanceOf(receiver) , 18);
   assertEq(eUSDC.balanceOf(holder) , 0);
//    assertEq(ERC20(address(eUSDT)).balanceOf(address(this)), 0);

}










receive() external payable {}

fallback() external payable{}




// helpers 

// function setUpData() internal {
//      stableInputs = {
//         destination: ZERO_ADDRESS,
//         origin: ZERO_ADDRESS,
//         oAmount: 0,
//         target: ZERO_ADDRESS,
//         tAmount: 0
//     }

//      defiInputs = {
//         aggregator: ZERO_ADDRESS,
//         plugin: ZERO_ADDRESS,
//         feeToken: ZERO_ADDRESS,
//         referrer: ZERO_ADDRESS,
//         referralFee: 0,
//         walletData: '0x',
//         swapData: '0x',
//     }

// }





}
