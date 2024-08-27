// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CCIPLocalSimulator} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {IRouterClient, WETH9, LinkToken, BurnMintERC677Helper} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {CrossChainNameServiceRegister} from "../src/CrossChainNameServiceRegister.sol";
import {CrossChainNameServiceReceiver} from "../src/CrossChainNameServiceReceiver.sol";
import {ICrossChainNameServiceLookup} from "../src/ICrossChainNameServiceLookup.sol";
import {CrossChainNameServiceLookup} from "../src/CrossChainNameServiceLookup.sol";

contract NameServiceTest is Test {
  CCIPLocalSimulator public ccipLocalSimulator;
  CrossChainNameServiceRegister public nameServiceRegister;
  CrossChainNameServiceReceiver public nameServiceReceiver;
  CrossChainNameServiceLookup public chainNameServiceLookup;
  CrossChainNameServiceLookup public desChainNameServiceLookup;

  address alice;
  address bob;

  string internal name = "alice.ccns";

  uint64 internal desChainSelector;

  function setUp() public {
    alice = makeAddr("alice");

    ccipLocalSimulator = new CCIPLocalSimulator();

    (
      uint64 chainSelector,
      IRouterClient sourceRouter,
      IRouterClient destinationRouter,
      WETH9 wrappedNative,
      LinkToken linkToken,
      BurnMintERC677Helper ccipBnM,
      BurnMintERC677Helper ccipLnM
    ) = ccipLocalSimulator.configuration();

    desChainSelector = chainSelector;

    chainNameServiceLookup = new CrossChainNameServiceLookup();
    desChainNameServiceLookup = new CrossChainNameServiceLookup();

    nameServiceRegister = new CrossChainNameServiceRegister(address(sourceRouter), address(chainNameServiceLookup));

    nameServiceReceiver = new CrossChainNameServiceReceiver(
      address(destinationRouter),
      address(desChainNameServiceLookup),
      chainSelector
    );
  }

  function testNameService() public {
    ccipLocalSimulator.requestLinkFromFaucet(address(nameServiceRegister), 1 ether);
    nameServiceRegister.enableChain(desChainSelector, address(nameServiceReceiver), 1 ether);

    chainNameServiceLookup.setCrossChainNameServiceAddress(address(nameServiceRegister));
    desChainNameServiceLookup.setCrossChainNameServiceAddress(address(nameServiceReceiver));

    vm.prank(alice);
    nameServiceRegister.register(name);

    assertEq(desChainNameServiceLookup.lookup(name), alice);
  }
}
