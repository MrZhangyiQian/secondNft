const { ethers } = require("hardhat");

async function main() {
  // 从之前的部署中加载地址
  const network = hre.network.name;
  const deployment = require(`../deployments/${network}.json`);
  
  const [deployer] = await ethers.getSigners();
  console.log(`Upgrading auction contract on ${network} with account: ${deployer.address}`);
  
  // 部署新版本的拍卖合约
  const AuctionV2 = await ethers.getContractFactory("Auction");
  const auctionLogicV2 = await AuctionV2.deploy();
  await auctionLogicV2.waitForDeployment();
  console.log("New Auction Logic deployed to:", auctionLogicV2.target);
  
  // 获取代理合约实例
  const Proxy = await ethers.getContractFactory("AuctionProxy");
  const proxy = Proxy.attach("PROXY_ADDRESS"); // 需要替换为实际的代理地址
  
  // 执行升级
  const upgradeTx = await proxy.upgradeTo(auctionLogicV2.target);
  await upgradeTx.wait();
  
  console.log("Upgrade completed! New implementation:", auctionLogicV2.target);
  
  // 更新部署信息
  deployment.auctionLogicV2 = auctionLogicV2.target;
  deployment.upgradedAt = Date.now();
  
  const fs = require("fs");
  fs.writeFileSync(
    `deployments/${network}.json`,
    JSON.stringify(deployment, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });