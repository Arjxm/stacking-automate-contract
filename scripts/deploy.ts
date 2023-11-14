import {ethers, run} from 'hardhat';

async function main() {

    const Staking = await ethers.getContractFactory('Staking');
    // @ts-ignore
    const staking = await Staking.deploy(process.env?.GELATO_AUTOMATE_ADDRESS, process.env?.FUND_OWNER);

  await staking.deployed();

  await run("verify:verify", {
      address: staking.address,
      constructorArguments: [process.env?.GELATO_AUTOMATE_ADDRESS, process.env?.FUND_OWNER],
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
