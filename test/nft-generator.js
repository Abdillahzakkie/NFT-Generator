const { expect, assert } = require("chai");
const { artifacts } = require("hardhat");
const { default: Web3 } = require("web3");
const NftGenerator = artifacts.require("NftGenerator");

const toWei = (_amount) => web3.utils.toWei(_amount.toString());

contract("NftGenerator", async ([deployer, user1, user2]) => {
	const tokenURI = "MY token URI";

	beforeEach(async () => {
		this.contract = await NftGenerator.new({ from: deployer });
	});

	describe("deployment", () => {
		it("should deploy contract properly", async () => {
			expect(this.contract.address).not.null;
			expect(this.contract.address).not.equal(undefined);
			expect(this.contract.address).not.equal("");
		});

		it("should set name properly", async () => {
			expect(await this.contract.name()).to.equal("NftGenerator");
		});

		it("should set symbol properly", async () => {
			expect(await this.contract.symbol()).to.equal("N-GEN");
		});
	});

	// describe("random function", () => {
	// 	it("should generate a word containing 4 random characters", async () => {
	// 		const _randowWord = await this.contract.random();
	// 		expect(_randowWord.split(" ").length).to.equal(4);
	// 	});
	// });

	describe("mint function", () => {
		let _reciept;

		beforeEach(async () => {
			const _fee = await this.contract.Fee();
			_reciept = await this.contract.mint({
				from: user1,
				value: _fee,
			});
		});

		it("should mint NFT properly", async () => {
			let _tokenId;
			for (let i = 0; i < _reciept.logs.length; ++i) {
				if (_reciept.logs[i].event === "Claimed") {
					const _args = _reciept.logs[i].args;
					_tokenId = _args.tokenId.toString();
				}
			}

			const _word = await this.contract.wordLists(_tokenId);
			console.log("_tokenId", _tokenId);
			console.log("word", _word);

			console.log(await this.contract.tokenURI(_tokenId));
			expect(_word).not.null;
			expect(_word).not.equal("");
		});

		it("should reject if amount is less than fee", async () => {
			try {
				await this.contract.mint({
					from: user1,
					value: "1",
				});
			} catch (error) {
				assert(
					error.message.includes(
						"NftGenerator: mint fee must be equal to 0.05 ether"
					)
				);
				return;
			}
			assert(false);
		});

		it("should set fee to contract address", async () => {
			expect(await web3.eth.getBalance(this.contract.address)).to.equal(
				(await this.contract.Fee()).toString()
			);
		});
	});

	describe("withdraw", () => {
		beforeEach(async () => {
			const _fee = await this.contract.Fee();
			await this.contract.mint({
				from: user1,
				value: _fee,
			});
			await this.contract.mint({
				from: user2,
				value: _fee,
			});
			await this.contract.mint({
				from: user1,
				value: _fee,
			});
			await this.contract.withdraw(toWei(0.1), { from: deployer });
		});

		it("should withdraw fee to contract address", async () => {
			expect(await web3.eth.getBalance(this.contract.address)).to.equal(
				toWei(0.05)
			);
		});
	});
});
