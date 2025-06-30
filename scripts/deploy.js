const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("Starting deployment on Core Testnet 2...");

  // Get the deployer account
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Get the contract factory
  const Election = await hre.ethers.getContractFactory("DecentralizedElection");

  console.log("Deploying DecentralizedElection contract...");

  // Deploy the contract without constructor arguments
  const election = await Election.deploy();

  // Wait for deployment
  await election.deployed();

  console.log("✅ Contract deployed successfully!");
  console.log("Contract address:", election.address);
  console.log("Deployer (Admin):", deployer.address);
  console.log("Transaction hash:", election.deployTransaction.hash);

  // Wait for block confirmations
  console.log("Waiting for 2 block confirmations...");
  await election.deployTransaction.wait(2);

  console.log("✅ Contract confirmed on blockchain!");

  // Deployment Summary
  console.log("\n" + "=".repeat(60));
  console.log("DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));
  console.log(`Contract Name       : DecentralizedElection`);
  console.log(`Network             : ${hre.network.name}`);
  console.log(`Contract Address    : ${election.address}`);
  console.log(`Admin Address       : ${deployer.address}`);
  console.log(`Gas Limit Estimate  : ${election.deployTransaction.gasLimit?.toString() || 'N/A'}`);
  console.log(`Block Number        : ${election.deployTransaction.blockNumber || 'Pending'}`);
  console.log("=".repeat(60));

  // Contract Verification (optional)
  if (hre.network.name === "core_testnet2") {
    console.log("\nStarting contract verification...");
    try {
      await hre.run("verify:verify", {
        address: election.address,
        constructorArguments: [], // No constructor args
      });
      console.log("✅ Contract verified successfully!");
    } catch (error) {
      console.log("❌ Contract verification failed:", error.message);
      console.log("You can manually verify the contract later.");
    }
  }

  // Save deployment details
  const deploymentInfo = {
    contractAddress: election.address,
    contractName: "DecentralizedElection",
    network: hre.network.name,
    admin: deployer.address,
    transactionHash: election.deployTransaction.hash,
    blockNumber: election.deployTransaction.blockNumber,
    timestamp: new Date().toISOString()
  };

  fs.writeFileSync(
    './deployment-info.json',
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("📝 Deployment info saved to deployment-info.json");

  // Next Steps
  console.log("\nNext steps:");
  console.log("1. Add candidates using addCandidate(name)");
  console.log("2. Start election using startElection()");
  console.log("3. Allow voters to vote using vote(candidateId)");
  console.log("4. End election using endElection()");
  console.log("5. View results using getWinner(), getTopNCandidates(n), etc.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
