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
		const deposit = 2;
		const preBalance1 = await instance.balances.call(recipient1);
		console.log("preBalance1: ", preBalance1.toString());
		const preBalance2 = await instance.balances.call(recipient2);
		console.log("preBalance2: ", preBalance2.toString());
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		const postBalance1 = await instance.balances.call(recipient1);
		console.log("TypeOf PostBal1: ", typeof(postBalance1));
		const postBalance2 = await instance.balances.call(recipient2);
		const amount1 = postBalance1 - preBalance1;
		console.log("amount1: ", amount1);
		const amount2 = postBalance2 - preBalance2;
		console.log("amount2: ", amount2);
		assert.strictEqual(amount1, amount2, "Failed to split even deposit into equal halves");
		assert.strictEqual(amount1, deposit / 2, "Failed to split deposit into correct amount")
	});

	it("Should log amount sent to contract correctly", async function () {
		const deposit = 3;
		const txObject = await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		assert.strictEqual(txObject.logs[0].args.amount.toString(), deposit, 
				"Failed to log amount sent to contract correctly");
	});
});