// Specifically request an abstraction for DemoToken
const DemoToken = artifacts.require('DemoToken');

const assertJump = (error) => {
  assert(error.message.search('revert') || error.message.search('invalid opcode'));
};

async function deployToken() {
  return DemoToken.new();
}

contract('DemoToken', (accounts) => {
  let instance;
  const owner = accounts[0];
  const user1 = accounts[1];
  const user2 = accounts[2];
  const user3 = accounts[3];

  beforeEach(async () => {
    instance = await deployToken();
    assert.ok(instance);
  });

  it('Check default totalSupply', async () => {
    const totalSupply = await instance.totalSupply();

    assert.equal(totalSupply.valueOf(), 0);
  });

  it('Check account balance', async () => {
    const balance = await instance.balanceOf(user1);

    assert.equal(balance.valueOf(), 0);
  });

  it('Check account balance after mintTokens', async () => {
    await instance.mintTokens(user1, 100);
    const balance = await instance.balanceOf(user1);

    assert.equal(balance.valueOf(), 100); // 0 + 100 = 100
  });

  it('Check totalSupply after mintTokens', async () => {
    await instance.mintTokens(owner, 100);
    const totalSupply = await instance.totalSupply();

    assert.equal(totalSupply.valueOf(), 100); // 0 + 100 = 100
  });

  it('Check status of minting', async () => {
    const status = await instance.mintingFinished();

    assert.equal(status.valueOf(), false);
  });

  it('Finish minting', async () => {
    await instance.finishMinting();
    const status = await instance.mintingFinished();

    assert.equal(status.valueOf(), true);
  });

  it('Check that owner can not mintTokens after finishMinting', async () => {
    await instance.finishMinting();

    try {
      await instance.mintTokens(owner, 100);
    } catch (error) {
      assertJump(error);
      return;
    }

    assert.fail('should have thrown before');
  });

  it('Check that tokens can be transfered', async () => {
    await instance.mintTokens(owner, 1000);
    await instance.transfer(user1, 100, { from: owner });
    const recipientBalance = await instance.balanceOf(user1);
    const senderBalance = await instance.balanceOf(owner);

    assert.equal(recipientBalance, 100);
    assert.equal(senderBalance, 1000 - 100);
  });

  it('Check that account can not transfer more tokens then have', async () => {
    try {
      await instance.mintTokens(owner, 1000);
      await instance.transfer(user1, 100, { from: owner });

      await instance.transfer(user2, 200, { from: user1 }); // user1 have 100 tokens
    } catch (error) {
      assertJump(error);
      return;
    }

    assert.fail('should have thrown before');
  });

  it('Check that account can transfer approved tokens', async () => {
    await instance.mintTokens(user1, 100);
    await instance.approve(user2, 50, { from: user1 });
    await instance.transferFrom(user1, user3, 50, { from: user2 });
    const recepientBalance = await instance.balanceOf(user3);
    const senderBalance = await instance.balanceOf(user1);

    assert.equal(recepientBalance.valueOf(), 50); // 0 + 50
    assert.equal(senderBalance.valueOf(), 50); // 100 - 50
  });

  it('Check that tokens can be approved', async () => {
    try {
      await instance.approve(user2, 1000000, { from: user1 }); // user1 have 0 tokens
    } catch (error) {
      assertJump(error);
      return;
    }

    assert.fail('should have thrown before');
  });

  it('Burn owner tokens from totalSupply', async () => {
    await instance.mintTokens(owner, 1000);
    await instance.burnTokens(100);
    const balance = await instance.balanceOf(owner);

    assert.equal(balance.valueOf(), 1000 - 100);

    const totalSupply = await instance.totalSupply();
    assert.equal(totalSupply.valueOf(), 1000 - 100);
  });

  it('Burn tokens allowed to spend by other user', async () => {
    await instance.mintTokens(owner, 100);
    await instance.mintTokens(user1, 200);

    const totalSupply = await instance.totalSupply();
    assert.equal(totalSupply.valueOf(), 300);

    await instance.approve(user2, 50, { from: user1 });
    await instance.burnFrom(user1, 50, { from: user2 }); // 200 - 50 = 150

    const balance = await instance.balanceOf(user1);
    assert.equal(balance.valueOf(), 150);

    const newTotalSupply = await instance.totalSupply();
    assert.equal(newTotalSupply.valueOf(), 250);
  });

  it('Exception when try to burn tokens by not allowed user', async () => {
    try {
      await instance.mintTokens(user1, 200);
      await instance.burnFrom(user1, 50, { from: user2 });
    } catch (error) {
      assertJump(error);
      return;
    }

    assert.fail('should have thrown before');
  });
});
