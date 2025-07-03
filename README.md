# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
  test result:
  PS D:\web3\secondNft> npx hardhat test test/Auction.test.js
[dotenv@17.0.1] injecting env (3) from .env – [tip] encrypt with dotenvx: https://dotenvx.com
Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> contracts/AuctionFactory.sol:15:8:
   |
15 |        uint256 _tokenId,
   |        ^^^^^^^^^^^^^^^^


Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> contracts/AuctionFactory.sol:16:8:
   |
16 |        uint256 _duration,
   |        ^^^^^^^^^^^^^^^^^


Warning: Unused function parameter. Remove or comment out the variable name to silence this warning.
  --> contracts/AuctionFactory.sol:17:8:
   |
17 |        address _priceFeed
   |        ^^^^^^^^^^^^^^^^^^


Compiled 3 Solidity files successfully (evm target: paris).
duplicate definition - Upgraded(address)
duplicate definition - Upgraded(address)


  Auction Contract
    Initialization
      ✔ should initialize auction correctly
    Bidding Logic
      ✔ should allow a bid and update highest bidder
      ✔ should revert if seller tries to bid
      ✔ should revert if bid is not higher than current
      ✔ should revert if auction has ended
    Ending Auction
      ✔ should end auction and transfer NFT to winner
      ✔ should return NFT if no bids
      ✔ should revert if called before auction ends
      ✔ should revert if called by unauthorized user
    Price Calculation
      ✔ should get correct ETH/USD price
      ✔ should calculate USD value of ETH correctly
    UUPS Upgrade Support
      ✔ should upgrade contract successfully
Proxy Owner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Bidder1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
AuctionV2 Implementation: 0xfbC22278A96299D91d41C453234d97b4F5Eb9B2d
      ✔ should only allow owner to upgrade


  13 passing (703ms)

··············································································································
|  Solidity and Network Configuration                                                                        │
·························|·················|···············|·················|································
|  Solidity: 0.8.28      ·  Optim: false   ·  Runs: 200    ·  viaIR: false   ·     Block: 30,000,000 gas     │
·························|·················|···············|·················|································
|  Methods                                                                                                   │
·························|·················|···············|·················|················|···············
|  Contracts / Methods   ·  Min            ·  Max          ·  Avg            ·  # calls       ·  usd (avg)   │
·························|·················|···············|·················|················|···············
|  Auction               ·                                                                                   │
·························|·················|···············|·················|················|···············
|      endAuction        ·         97,216  ·      107,880  ·        102,548  ·             2  ·           -  │
·························|·················|···············|·················|················|···············
|      placeBid          ·              -  ·            -  ·        221,132  ·             3  ·           -  │
·························|·················|···············|·················|················|···············
|  AuctionV2             ·                                                                                   │
·························|·················|···············|·················|················|···············
|      upgradeToAndCall  ·              -  ·            -  ·         38,511  ·             1  ·           -  │
·························|·················|···············|·················|················|···············
|  MyNFT                 ·                                                                                   │
·························|·················|···············|·················|················|···············
|      approve           ·         49,009  ·       49,021  ·         49,020  ·            26  ·           -  │
·························|·················|···············|·················|················|···············
|      mint              ·              -  ·            -  ·         91,307  ·            26  ·           -  │
·························|·················|···············|·················|················|···············
|      safeTransferFrom  ·         64,604  ·       64,616  ·         64,615  ·            13  ·           -  │
·························|·················|···············|·················|················|···············
|  Deployments                             ·                                 ·  % of limit    ·              │
·························|·················|···············|·················|················|···············
|  Auction               ·              -  ·            -  ·      2,529,288  ·         8.4 %  ·           -  │
·························|·················|···············|·················|················|···············
|  AuctionV2             ·              -  ·            -  ·      2,553,827  ·         8.5 %  ·           -  │
·························|·················|···············|·················|················|···············
|  MockV3Aggregator      ·              -  ·            -  ·        408,698  ·         1.4 %  ·           -  │
·························|·················|···············|·················|················|···············
|  MyNFT                 ·              -  ·            -  ·      1,788,695  ·           6 %  ·           -  │
·························|·················|···············|·················|················|···············
|  Key                                                                                                       │
··············································································································
|  ◯  Execution gas for this method does not include intrinsic gas overhead                                  │
··············································································································
|  △  Cost was non-zero but below the precision setting for the currency display (see options)               │
··············································································································
|  Toolchain:  hardhat                                                                                       │
··············································································································
