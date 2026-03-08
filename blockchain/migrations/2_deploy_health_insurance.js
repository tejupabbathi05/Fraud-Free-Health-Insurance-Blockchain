const HealthInsurance = artifacts.require("HealthInsurance");

module.exports = function (deployer) {
  deployer.deploy(HealthInsurance);
};

