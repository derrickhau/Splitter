const Splitter = artifacts.require("./Splitter.sol");

contract("Splitter", accounts => {
	let owner, recipient1, recipient2;

	beforeEach("Establish accounts for each test", async function () {
		[ owner, recipient1, recipient2 ] = accounts;
		instance = await Splitter.new({ from: owner });
	});

	it("PreBalances should be zero", async function () {
		let preBalance1 = await instance.balances.call(recipient1);
		let preBalance2 = await instance.balances.call(recipient2);
		assert.equal(preBalance1.toNumber(), 0, "Failed to deploy with recipient1 account equalling zero");
		assert.equal(preBalance2.toNumber(), 0, "Failed to deploy with recipient2 account equalling zero");
	});

	it("Should split even deposit correctly", async function () {
		let deposit = 2;
		let preBalance1 = await instance.balances.call(recipient1);
		console.log("preBalance1: ", preBalance1.toNumber());
		let preBalance2 = await instance.balances.call(recipient2);
		console.log("preBalance2: ", preBalance2.toNumber());
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		let postBalance1 = await instance.balances.call(recipient1);
		let postBalance2 = await instance.balances.call(recipient2);
		let amount1 = postBalance1 - preBalance1;
		console.log("amount1: ", amount1);
		let amount2 = postBalance2 - preBalance2;
		console.log("amount2: ", amount2);
		assert.strictEqual(amount1, amount2, "Failed to split even deposit into equal halves");
		assert.strictEqual(amount1, deposit / 2, "Failed to split deposit into correct amount")
	});

	it("Should log amount sent to contract correctly", async function () {
		let deposit = 3;
		let preBalance1 = await instance.balances.call(recipient1);
		let preBalance2 = await instance.balances.call(recipient2);
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit })
		.then (txObject => {
			assert.strictEqual(txObject.logs[0].args.amount.toNumber(), deposit, 
				"Failed to log amount sent to contract correctly");
		});
	});
});