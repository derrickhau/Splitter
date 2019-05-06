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
		const amount1 = await instance.balances.call(recipient1);
		const amount2 = await instance.balances.call(recipient2);
		assert.strictEqual(amount1.toString(), amount2.toString(), "Failed to split even deposit into equal halves");
		assert.strictEqual(amount1.toString(), (deposit / 2).toString(), "Failed to split deposit into correct amount");
	});

	it("Should log amount sent to contract correctly", async function () {
		const deposit = 3;
		const txObject = await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		assert.strictEqual(txObject.logs[0].args.amount.toString(), deposit.toString(), 
			"Failed to log amount sent to contract correctly");
	});

	it("Should log withdraw correctly and zero account balance", async function () {
		const deposit = 2; // Must be even number
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		let postBalance1 = await instance.balances.call(recipient1);
		const txObject = await instance.withdraw({ from: recipient1 });
		postBalance1 = await instance.balances.call(recipient1);
		const webCallBalance = await web3.eth.getBalance(recipient1);
		assert.strictEqual(txObject.logs[0].args.amount.toString(), (deposit / 2).toString(),
			"Failed to log withdrawl correctly");
		assert.strictEqual(postBalance1.toString(), "0",
			"Failed to zero account balance after withdrawl");
	});

	it("Should correctly calculate gas cost and withdrawl amount", async function () {
		const BN = web3.utils.BN;
		const deposit = 2; // Must be even number
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });

		const preBalance1BN = new BN(await web3.eth.getBalance(recipient1));
		
		const txObject = await instance.withdraw({ from: recipient1 });
		const accountBalance1 = await instance.balances.call(recipient1);
		
		const gasPrice = await web3.eth.getTransaction(txObject.tx)
			.then (tx => tx.gasPrice);
		const gasUsed= await web3.eth.getTransactionReceipt(txObject.tx)
			.then (receipt => receipt.gasUsed);
		const totalGasCost = gasPrice * gasUsed;

		const postBalance1BN = new BN(await web3.eth.getBalance(recipient1));
		
		const withdrawlAmountBN = new BN(deposit / 2);
		const postMinusWithdrawlAmountBN = new BN(postBalance1BN).sub(withdrawlAmountBN);
		const postPlusGasBN = new BN(postBalance1BN.add(new BN(totalGasCost)))

		assert.strictEqual(preBalance1BN.sub(postMinusWithdrawlAmountBN).toString(), totalGasCost.toString(),
			"Failed to accurately calculate gas cost of withdrawl");
		assert.strictEqual(txObject.logs[0].args.amount.toString(), withdrawlAmountBN.toString(),
			"Failed to log withdrawl amount correctly");
		assert.strictEqual(accountBalance1.toString(), "0",
			"Failed to zero account balance after withdrawl");
		assert.strictEqual((postPlusGasBN.sub(preBalance1BN)).toString(), withdrawlAmountBN.toString(),
			"Failed to withdraw correct amount");
	});

	it("Should pause contract and prevent withdrawl", async function () {
		const deposit = 2;
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		await instance.contractPaused(true, { from: owner });
		return instance.withdraw({ from: recipient1 }).then(
			() => Promise.reject(new Error('Contract is paused')),
			err => assert.instanceOf(err, Error)
		)
	});
});