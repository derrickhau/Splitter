const Splitter = artifacts.require("./Splitter.sol");

contract("Splitter", accounts => {
	const [ owner, recipient1, recipient2 ] = accounts;

	beforeEach("Deploy fresh, unpaused Splitter", async function () {
		instance = await Splitter.new(false, { from: owner });
	});

	it("PreBalances should be zero", async function () {
		const preBalance1 = await instance.balances.call(recipient1);
		const preBalance2 = await instance.balances.call(recipient2);
		assert.equal(preBalance1.toString(), 0, "Failed to deploy with recipient1 account equalling zero");
		assert.equal(preBalance2.toString(), 0, "Failed to deploy with recipient2 account equalling zero");
	});

	it("Should split even deposit correctly", async function () {
		const deposit = 2; // Must be even number
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		const postBalance1 = await instance.balances.call(recipient1);
		const postBalance2 = await instance.balances.call(recipient2);
		assert.strictEqual(amount1, amount2, "Failed to split even deposit into equal halves");
		assert.strictEqual(amount1, deposit / 2, "Failed to split deposit into correct amount")
	});

	it("Should log amount sent, from owner, to recipients, to contract correctly", async function () {
		const deposit = 3;
		const txObject = await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		assert.strictEqual(txObject.logs[0].args.amount.toString(), deposit, 
			"Failed to log amount sent to contract correctly");
		assert.strictEqual(txObject.logs[0].args.owner, account[0], 
			"Failed to log address sent from correctly");
		assert.strictEqual(txObject.logs[0].args.recipient1, account[1],
			"Failed to log address sent from correctly");
		assert.strictEqual(txObject.logs[0].args.recipient2, account[2],
			"Failed to log address sent from correctly");
	});

	it("Should withdraw correctly", async function () {
		const deposit = 2; // Must be even number
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		let postBalance1 = await instance.balances.call(recipient1);
		console.log("Balance before withdrawl: " postBalance1.toString(10);
		const txObject = await instance.withdrawl({ from: recipient1 });
		postBalance1 = await instance.balances.call(recipient1);
		console.log("Balance after withdrawl: " postBalance1).toString(10);
		assert.strictEqual(txObject.logs[0].args.amount.toString(10), "1",
			"Failed to log withdrawl correctly");
	});

	it("Should protect when onlyOwner is violated", async function () {
		const deposit = 2;		
		assert.throws(
			() => { instance.splitFunds(recipient1, recipient2, { from: recipient1, value: deposit }); },
			{
				name: 'onlyOwner Error',
				message: 'Access restrict to owner'
			});
	});
});