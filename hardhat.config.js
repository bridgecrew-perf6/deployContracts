require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const {
  ETHERSCAN_API_KEY,
  FANTOMSCAN_API_KEY,
  INFURA_API_KEY,
  PRIVATE_KEY,
} = require("./secrets.json");

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

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  etherscan: {
    apiKey: {
      ropsten: ETHERSCAN_API_KEY,
      rinkeby: ETHERSCAN_API_KEY,
      opera: FANTOMSCAN_API_KEY,
      ftmTestnet: FANTOMSCAN_API_KEY,
    },
  },
  defaultNetwork: "ropsten",
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    opera: {
      url: "https://rpc.fantom.network/",
      accounts: [PRIVATE_KEY],
    },
  },
};
