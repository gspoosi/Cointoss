const Cointoss = artifacts.require("Cointoss");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Cointoss).then(function(instance){
  	});
  };
