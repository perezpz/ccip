// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Importing necessary components from the Chainlink and Forge Standard libraries for testing.
import "forge-std/Test.sol";
import {stdStorage, StdStorage} from "forge-std/Test.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Sender} from "../src/estimate-gas/Sender.sol";
import {Receiver} from "../src/estimate-gas/Receiver.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink/local/src/ccip/CCIPLocalSimulatorFork.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v5.0.2/contracts/token/ERC20/IERC20.sol";
import {BurnMintERC677} from "@chainlink/contracts-ccip/src/v0.8/shared/token/ERC677/BurnMintERC677.sol";
import {MockCCIPRouter} from "@chainlink/contracts-ccip/src/v0.8/ccip/test/mocks/MockRouter.sol";
import {TransferUSDC} from "../src/TransferUSDC.sol";

contract TransferUSDCTest is Test {
  // Defining the variables for SendeReceive.
  Sender public sender;
  Receiver public receiver;
  BurnMintERC677 public link;
  MockCCIPRouter public router;
  // A specific chain selector for identifying the chain.
  uint64 public chainSelector = 16015286601757825753;

  using stdStorage for StdStorage;

  CCIPLocalSimulatorFork public ccipLocalSimulatorFork;

  IERC20 private i_usdcToken;

  uint256 ethSepoliaFork;
  uint256 avalancheFujiFork;

  Register.NetworkDetails ethSepoliaNetworkDetails;
  Register.NetworkDetails avalancheFujiNetworkDetails;

  address alice;

  TransferUSDC public avalancheFujiTransferUSDC;

  function setUp() public {
    initSendeReceive();

    alice = makeAddr("alice");

    string memory ETHEREUM_SEPOLIA_RPC_URL = vm.envString("ETHEREUM_SEPOLIA_RPC_URL");
    string memory AVALANCHE_FUJI_RPC_URL = vm.envString("AVALANCHE_FUJI_RPC_URL");

    ethSepoliaFork = vm.createFork(ETHEREUM_SEPOLIA_RPC_URL);
    avalancheFujiFork = vm.createSelectFork(AVALANCHE_FUJI_RPC_URL);

    i_usdcToken = IERC20(0x9d2BC6513f59061D6cC2f027e41e5b238e946E82);

    ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();

    vm.makePersistent(address(ccipLocalSimulatorFork));

    assertEq(vm.activeFork(), avalancheFujiFork);

    avalancheFujiNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

    assertEq(avalancheFujiNetworkDetails.routerAddress, 0xF694E193200268f9a4868e4Aa017A0118C9a8177);

    LinkTokenInterface i_linkToken = LinkTokenInterface(avalancheFujiNetworkDetails.linkAddress);

    avalancheFujiTransferUSDC = new TransferUSDC(
      avalancheFujiNetworkDetails.routerAddress,
      address(i_linkToken),
      address(i_usdcToken)
    );

    // console.log(
    //   address(this),
    //   avalancheFujiNetworkDetails.routerAddress,
    //   address(avalancheFujiTransferUSDC),
    //   "msg.sender"
    // );

    vm.selectFork(ethSepoliaFork);
    ethSepoliaNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
  }

  function initSendeReceive() public {
    router = new MockCCIPRouter();
    link = new BurnMintERC677("ChainLink Token", "LINK", 18, 10 ** 27);
    // Sender and Receiver contracts are deployed with references to the router and LINK token.
    sender = new Sender(address(router), address(link));
    receiver = new Receiver(address(router));
    // Configuring allowlist settings for testing cross-chain interactions.
    sender.allowlistDestinationChain(chainSelector, true);
    receiver.allowlistSourceChain(chainSelector, true);
    receiver.allowlistSender(address(sender), true);
  }

  function test_TransferUSDC() public {
    vm.selectFork(avalancheFujiFork);

    avalancheFujiTransferUSDC.allowlistDestinationChain(ethSepoliaNetworkDetails.chainSelector, true);
    assertEq(avalancheFujiTransferUSDC.allowlistedChains(ethSepoliaNetworkDetails.chainSelector), true);

    // 在Avalanche Fuji上，向TransferUSDC.sol合约充值3个LINK
    ccipLocalSimulatorFork.requestLinkFromFaucet(address(avalancheFujiTransferUSDC), 3 ether);

    deal(address(i_usdcToken), address(this), 1 ether);
    assertEq(i_usdcToken.balanceOf(address(this)), 1 ether);

    uint256 gasUsed = sendMessage(50);
    uint64 gasLimit = uint64(gasUsed * 110 / 100);

    avalancheFujiTransferUSDC.transferUsdc(ethSepoliaNetworkDetails.chainSelector, alice, 1000000, gasLimit);
  }

  function sendMessage(uint256 iterations) private returns (uint256 gasUsed){
    vm.recordLogs(); // Starts recording logs to capture events.
    sender.sendMessagePayLINK(
      chainSelector,
      address(receiver),
      iterations,
      400000 // A predefined gas limit for the transaction.
    );
    // Fetches recorded logs to check for specific events and their outcomes.
    Vm.Log[] memory logs = vm.getRecordedLogs();
    bytes32 msgExecutedSignature = keccak256("MsgExecuted(bool,bytes,uint256)");

    for (uint i = 0; i < logs.length; i++) {
      if (logs[i].topics[0] == msgExecutedSignature) {
        (, , gasUsed) = abi.decode(logs[i].data, (bool, bytes, uint256));
        console.log("Number of iterations %d - Gas used: %d", iterations, gasUsed);
      }
    }
  }
}
