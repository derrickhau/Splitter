const Splitter = artifacts.require("./Splitter.sol");

contract("Splitter", accounts => {
	let owner;
	let recipient1;
	let recipient2;

	beforeEach("Establish accounts for each test", async function () {
		owner = accounts[0];
		recipient1 = accounts[1];
		recipient2 = accounts[2];
		instance = await Splitter.new({ from: owner });
	});

	it("Should split even deposit correctly", async function () {
		let deposit = 2;
		let preBalance1 = await instance.balances.call(recipient1);
		let preBalance2 = await instance.balances.call(recipient2);
		await instance.splitFunds(recipient1, recipient2, { from: owner, value: deposit });
		let postBalance1 = await instance.balances.call(recipient1);
		let postBalance2 = await instance.balances.call(recipient2);
		let amount1 = preBalance1 - postBalance1;
		let amount2 = preBalance2 - postBalance2;
		assert.strictEqual(amount1, amount2, "Failed to split even deposit correctly");
	});
});