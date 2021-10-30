require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
const ALCHEMY_API_KEY = "API KEY...";

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const KOVAN_PRIVATE_KEY = "PREVATE KEY...";
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    kovan: {
      url: `https://kovan.infura.io/v3/${ALCHEMY_API_KEY}`,
      accounts: [`0x${KOVAN_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: 'MW11564BX8RIINE9VPN3RUS39XV1EX7WA7'
  }
};
