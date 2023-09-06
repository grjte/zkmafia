const main = async () => {
    const [deployer] = await hre.ethers.getSigners();
    const accountBalance = await deployer.getBalance();

    console.log("Deploying contracts with account: ", deployer.address);
    console.log("Account balance: ", accountBalance.toString());

    const pairingFactory = await hre.ethers.getContractFactory("Pairing");
    const pairingContract = await pairingFactory.deploy();
    await pairingContract.deployed();
    const semaphoreVerifierFactory = await hre.ethers.getContractFactory("SemaphoreVerifier", {
        libraries: {
            Pairing: pairingContract.address
        }
    });
    const semaphoreVerifierContract = await semaphoreVerifierFactory.deploy();
    await semaphoreVerifierContract.deployed();

    const poseidonFactory = await hre.ethers.getContractFactory("PoseidonT3");
    const poseidonContract = await poseidonFactory.deploy();
    await poseidonContract.deployed();

    const incBinaryTreeFactory = await hre.ethers.getContractFactory("IncrementalBinaryTree", {
        libraries: {
            PoseidonT3: poseidonContract.address
        }
    });
    const incBinaryTreeContract = await incBinaryTreeFactory.deploy();
    await incBinaryTreeContract.deployed();

    const semaphoreFactory = await hre.ethers.getContractFactory("Semaphore", {
        libraries: {
            IncrementalBinaryTree: incBinaryTreeContract.address,
        }
    });
    const semaphoreContract = await semaphoreFactory.deploy(semaphoreVerifierContract.address);
    await semaphoreContract.deployed();

    const zkMafiaInstanceFactory = await hre.ethers.getContractFactory("ZKMafiaInstance", {
        libraries: {
            IncrementalBinaryTree: incBinaryTreeContract.address,
        }
    });
    const zkMafiaInstanceContract = await zkMafiaInstanceFactory.deploy();
    await zkMafiaInstanceContract.deployed();

    const zkMafiaFactory = await hre.ethers.getContractFactory("ZKMafia", {
        libraries: {
            IncrementalBinaryTree: incBinaryTreeContract.address,
            ZKMafiaInstance: zkMafiaInstanceContract.address
        }
    });
    const zkMafiaContract = await zkMafiaFactory.deploy(semaphoreContract.address);
    await zkMafiaContract.deployed();

    console.log("ZKMafia Address: ", zkMafiaContract.address);
  };

  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };

  runMain();