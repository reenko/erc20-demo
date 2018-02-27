const Token = artifacts.require('DemoToken');

module.exports = async (deployer) => {
  await deployer.deploy(Token);
};
