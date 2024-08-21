// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from 'forge-std/Script.sol';
import './Helper.sol';
import {XNFT} from '../src/XNFT.sol';

contract XNFTScript is Script, Helper {
  function setUp() public {}

  function run(SupportedNetworks network) public {
    uint256 deployerPrivateKey = vm.envUint('TEST_2_PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);

    (address ccipRouterAddress, address linkTokenAddress, uint64 currentChainSelecor, ) = getConfigFromNetwork(network);

    XNFT nft = new XNFT(ccipRouterAddress, linkTokenAddress, currentChainSelecor);

    console.log('XNFT deployed to ', address(nft));

    vm.stopBroadcast();
  }
}
