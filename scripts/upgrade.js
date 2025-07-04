// scripts/testUpgrade.js
const { ethers, upgrades } = require("hardhat");
const fs = require("fs");

async function main() {
  const network = hre.network.name;
  const [deployer] = await ethers.getSigners();

  console.log(`Deploying contracts with account: ${deployer.address}`);

  // 1. 部署 NFT 合约
  const MyNFT = await ethers.getContractFactory("MyNFT");
  const nft = await MyNFT.deploy();
  await nft.waitForDeployment();
  console.log("MyNFT deployed to:", nft.target);

  // 2. 铸造 NFT
  const tokenId = 0;
  const mintTx = await nft.mint(deployer.address);
  await mintTx.wait();
  console.log(`NFT ID ${tokenId} 已铸造给 ${deployer.address}`);
  console.log("NFT当前所有者:", await nft.ownerOf(tokenId));

  // 3. 部署工厂合约（可选）
  const AuctionFactory = await ethers.getContractFactory("AuctionFactory");
  const factory = await AuctionFactory.deploy();
  await factory.waitForDeployment();
  console.log("AuctionFactory deployed to:", factory.target);

  // 4. 使用 Upgrades 插件部署拍卖代理合约
  const SEPOLIA_FEED = "0x694AA1769357215DE4FAC081bf1f309aDC325306";
  const duration = 3600;

  console.log("通过工厂创建拍卖...");

  const auctionProxy = await upgrades.deployProxy(
    await ethers.getContractFactory("Auction"),
    [
      deployer.address,     // _seller
      nft.target,           // _nftContract
      tokenId,              // _tokenId
      duration,             // _duration
      SEPOLIA_FEED          // _priceFeed
    ],
    { initializer: "initialize" }
  );
  await auctionProxy.waitForDeployment();
  const auctionProxyAddress = await auctionProxy.getAddress();
  console.log("Auction Proxy deployed to:", auctionProxyAddress);

  // ✅ 获取 ProxyAdmin 地址（推荐方式）
  const proxyAdminAddress = await upgrades.erc1967.getAdminAddress(auctionProxyAddress);
  console.log("ProxyAdmin 地址:", proxyAdminAddress);

  // ✅ 获取当前逻辑合约地址
  const implementationAddress = await upgrades.erc1967.getImplementationAddress(auctionProxyAddress);
  console.log("当前逻辑合约地址:", implementationAddress);

  // ✅ 构建部署信息
  const deploymentInfo = {
    network: network,
    nftAddress: nft.target,
    factoryAddress: factory.target,
    proxyAddress: auctionProxyAddress,
    proxyAdmin: proxyAdminAddress,
    implementation: implementationAddress,
    timestamp: Date.now()
  };

  if (!fs.existsSync("deployments")) {
    fs.mkdirSync("deployments");
  }

  fs.writeFileSync(
    `deployments/${network}.json`,
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("部署完成！");

  // ✅ 将 NFT 转移到代理合约中
  const transferTx = await nft["safeTransferFrom(address,address,uint256)"](
    deployer.address,
    auctionProxyAddress,
    tokenId
  );
  await transferTx.wait();
  console.log("NFT已转移至拍卖合约");

  // ✅ 查询拍卖信息
  const auction = await ethers.getContractAt("Auction", auctionProxyAddress);
  const auctionInfo = await auction.auction();

  console.log("拍卖卖家:", auctionInfo.seller);
  console.log("NFT合约地址:", auctionInfo.nftContract);
  console.log("Token ID:", auctionInfo.tokenId.toString());
  console.log("开始时间:", new Date(Number(auctionInfo.startTime) * 1000));
  console.log("结束时间:", new Date(Number(auctionInfo.endTime) * 1000));
  console.log("NFT当前所有者:", await nft.ownerOf(tokenId));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });