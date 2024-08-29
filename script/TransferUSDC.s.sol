// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TransferUSDC} from "../src/TransferUSDC.sol";

contract TransferUSDCScript is Script {
  function run() public {
    uint256 deployerPrivateKey = vm.envUint("TEST_2_PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    address ccipRouter = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
    address linkToken = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    address usdcToken = 0x5425890298aed601595a70AB815c96711a31Bc65;

    TransferUSDC transferUSDC = new TransferUSDC(ccipRouter, linkToken, usdcToken);

    console.log("TransferUSDC deployed at address:", address(transferUSDC));
    vm.stopBroadcast();
  }
}
