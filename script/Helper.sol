// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

contract Helper {
  enum SupportedNetworks {
    ETHEREUM_SEPOLIA, // 0
    BASE_SEPOLIA, // 6
    AVALANCHE_FUJI, // 1
    ARBITRUM_SEPOLIA // 2
  }

  mapping(SupportedNetworks enumValue => string) public networks;

  // Chain IDs
  uint64 constant chainIdEthereumSepolia = 16015286601757825753;
  uint64 constant chainIdBaseSepolia = 10344971235874465080;
  uint64 constant chainIdAvalancheFuji = 14767482510784806043;
  uint64 constant chainIdArbitrumSepolia = 3478487238524512106;

  // Router addresses
  address constant routerEthereumSepolia = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
  address constant routerBaseSepolia = 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93;
  address constant routerAvalancheFuji = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
  address constant routerArbitrumSepolia = 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165;

  // Link addresses (can be used as fee)
  address constant linkEthereumSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
  address constant linkBaseSepolia = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410;
  address constant linkAvalancheFuji = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
  address constant linkArbitrumSepolia = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;

  // Wrapped native addresses
  address constant wethEthereumSepolia = 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534;
  address constant wethBaseSepolia = 0x4200000000000000000000000000000000000006;
  address constant wavaxAvalancheFuji = 0xd00ae08403B9bbb9124bB305C09058E32C39A48c;
  address constant wethArbitrumSepolia = 0xE591bf0A0CF924A0674d7792db046B23CEbF5f34;

  // CCIP-BnM addresses
  address constant ccipBnMEthereumSepolia = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;
  address constant ccipBnMBaseSepolia = 0x88A2d74F47a237a62e7A51cdDa67270CE381555e;
  address constant ccipBnMArbitrumSepolia = 0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D;
  address constant ccipBnMAvalancheFuji = 0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4;

  // CCIP-LnM addresses
  address constant ccipLnMEthereumSepolia = 0x466D489b6d36E7E3b824ef491C225F5830E81cC1;
  address constant clCcipLnMBaseSepolia = 0xA98FA8A008371b9408195e52734b1768c0d1Cb5c;
  address constant clCcipLnMArbitrumSepolia = 0x139E99f0ab4084E14e6bb7DacA289a91a2d92927;
  address constant clCcipLnMAvalancheFuji = 0x70F5c5C40b873EA597776DA2C21929A8282A3b35;

  constructor() {
    networks[SupportedNetworks.ETHEREUM_SEPOLIA] = 'Ethereum Sepolia';
    networks[SupportedNetworks.BASE_SEPOLIA] = "Base Sepolia";
    networks[SupportedNetworks.ARBITRUM_SEPOLIA] = 'Arbitrum Sepolia';
    networks[SupportedNetworks.AVALANCHE_FUJI] = 'Avalanche Fuji';
  }

  function getConfigFromNetwork(
    SupportedNetworks network
  ) internal pure returns (address router, address linkToken, uint64 chainId, address wrappedNative) {
    if (network == SupportedNetworks.ETHEREUM_SEPOLIA) {
      return (routerEthereumSepolia, linkEthereumSepolia, chainIdEthereumSepolia, wethEthereumSepolia);
    } else if(network == SupportedNetworks.BASE_SEPOLIA) {
      return (routerBaseSepolia, linkBaseSepolia, chainIdBaseSepolia, wethBaseSepolia);
    } else if (network == SupportedNetworks.ARBITRUM_SEPOLIA) {
      return (routerArbitrumSepolia, linkArbitrumSepolia, chainIdArbitrumSepolia, wethArbitrumSepolia);
    } else if (network == SupportedNetworks.AVALANCHE_FUJI) {
      return (routerAvalancheFuji, linkAvalancheFuji, chainIdAvalancheFuji, wavaxAvalancheFuji);
    }
  }
}
