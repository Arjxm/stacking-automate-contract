import { ethers, run } from 'hardhat';
async function main() {
  const Staking = await ethers.getContractFactory('Staking');
  const staking = await Staking.deploy("0xB3f5503f93d5Ef84b06993a1975B9D21B962892F", "0x2d658014cA9846f79658fD6aA39959FAC3b6784C");

  await staking.deployed();

  await run("verify:verify", {
      address: staking.address,
      constructorArguments: ["0xB3f5503f93d5Ef84b06993a1975B9D21B962892F", "0x2d658014cA9846f79658fD6aA39959FAC3b6784C"],
  })

  console.log('Staking deployed to:', staking.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
