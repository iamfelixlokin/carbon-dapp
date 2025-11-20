const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  // Deploy Token
  const CarbonToken = await hre.ethers.getContractFactory("CarbonToken");
  const token = await CarbonToken.deploy(deployer.address);
  await token.waitForDeployment();
  console.log("CarbonToken deployed:", await token.getAddress());

  // Deploy Tracker
  const CarbonTracker = await hre.ethers.getContractFactory("CarbonTracker");
  const tracker = await CarbonTracker.deploy(await token.getAddress());
  await tracker.waitForDeployment();
  console.log("CarbonTracker deployed:", await tracker.getAddress());

  // Transfer ownership of CARBON to Tracker
  await token.transferOwnership(await tracker.getAddress());
  console.log("Ownership transferred!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

