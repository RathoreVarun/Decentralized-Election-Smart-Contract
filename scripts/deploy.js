const hre = require("hardhat");

async function main() {
  console.log("Starting deployment on Core Testnet 2...");
  
  // Get the deployer account
  const [deployer] = await hre.ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  // Election name for the contract
  const electionName = "Decentralized Presidential Election 2024";
  
  // Get the contract factory
  const Project = await hre.ethers.getContractFactory("Project");
  
  console.log("Deploying Decentralized Election Smart Contract...");
  
  // Deploy the contract
  const project = await Project.deploy(electionName);
  
  // Wait for the contract to be deployed
  await project.deployed();
  
  console.log("✅ Contract deployed successfully!");
  console.log("Contract address:", project.address);
  console.log("Election name:", electionName);
  console.log("Deployer (Owner):", deployer.address);
  console.log("Transaction hash:", project.deployTransaction.hash);
  
  // Wait for a few block confirmations
  console.log("Waiting for block confirmations...");
  await project.deployTransaction.wait(2);
  
  console.log("✅ Contract confirmed on blockchain!");
  
  // Display deployment summary
  console.log("\n" + "=".repeat(60));
  console.log("DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));
  console.log(`Contract Name: Decentralized Election Smart Contract`);
  console.log(`Network: Core Testnet 2`);
  console.log(`Contract Address: ${project.address}`);
  console.log(`Election Name: ${electionName}`);
  console.log(`Owner Address: ${deployer.address}`);
  console.log(`Gas Used: ${project.deployTransaction.gasLimit?.toString() || 'N/A'}`);
  console.log(`Block Number: ${project.deployTransaction.blockNumber || 'Pending'}`);
  console.log("=".repeat(60));
  
  // Verify contract on Core Testnet 2 explorer (optional)
  if (hre.network.name === "core_testnet2") {
    console.log("\nStarting contract verification...");
    try {
      await hre.run("verify:verify", {
        address: project.address,
        constructorArguments: [electionName],
      });
      console.log("✅ Contract verified successfully!");
    } catch (error) {
      console.log("❌ Contract verification failed:", error.message);
      console.log("You can manually verify the contract later.");
    }
  }
  
  // Save deployment info to a file
  const fs = require('fs');
  const deploymentInfo = {
    contractAddress: project.address,
    contractName: "Project",
    electionName: electionName,
    network: hre.network.name,
    deployer: deployer.address,
    transactionHash: project.deployTransaction.hash,
    blockNumber: project.deployTransaction.blockNumber,
    timestamp: new Date().toISOString()
  };
  
  fs.writeFileSync(
    './deployment-info.json', 
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log("📝 Deployment info saved to deployment-info.json");
  console.log("\nNext steps:");
  console.log("1. Add candidates using addCandidate() function");
  console.log("2. Register voters using registerVoter() function");
  console.log("3. Start voting using startVoting() function");
  console.log("4. Voters can cast votes using vote() function");
  console.log("5. End voting using endVoting() function");
  console.log("6. Check results using getWinner() function");
}

// Run the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
