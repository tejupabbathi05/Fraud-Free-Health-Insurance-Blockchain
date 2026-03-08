module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Ganache local blockchain
      port: 7545,            // Ganache GUI default port
      network_id: "*",       // Match any network id
    },
  },

  compilers: {
    solc: {
      version: "0.8.17",     // Solidity version used in HealthInsurance.sol
      settings: {
        optimizer: {
          enabled: true,     // Reduce gas cost
          runs: 200
        }
      }
    },
  },
};
