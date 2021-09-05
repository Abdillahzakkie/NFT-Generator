const { expect, assert } = require("chai");
const { artifacts } = require("hardhat");
const NftGenerator = artifacts.require("NftGenerator");

contract("NftGenerator", async ([deployer, user1, user2]) => {
	const tokenURI = "MY token URI";

	beforeEach(async () => {
		this.contract = await NftGenerator.new({ from: deployer });
	});

	describe("deployment", () => {
		it("should deploy contract properly", async () => {
			expect(this.contract.address).not.equal("");
			expect(this.contract.address).not.equal(undefined);
			expect(this.contract.address).not.equal(null);
		});

		it("should set name properly", async () => {
			expect(await this.contract.name()).to.equal("NftGenerator");
		});

		it("should set symbol properly", async () => {
			expect(await this.contract.symbol()).to.equal("N-GEN");
		});
	});

	describe("random function", () => {
		it("should generate a word containing 4 random characters", async () => {
			const _randowWord = await this.contract.random();
			expect(_randowWord.split(" ").length).to.equal(4);
		});
	});

	describe("claim function", () => {
		let _reciept;

		beforeEach(async () => {
			const _fee = await this.contract.Fee();
			_reciept = await this.contract.claim(tokenURI, {
				from: user1,
				value: _fee,
			});
		});

		it("should claim NFT properly", async () => {
			let _tokenId;
			for (let i = 0; i < _reciept.logs.length; ++i) {
				if (_reciept.logs[i].event === "Claimed") {
					const _args = _reciept.logs[i].args;
					_tokenId = _args.tokenId.toString();
				}
			}

			const _word = await this.contract.wordLists(_tokenId);
			console.log("word", _word);

			expect(await this.contract.tokenURI(_tokenId)).to.equal(tokenURI);
			expect(_word).not.null;
			expect(_word).not.equal("");
		});

		it("should reject if amount is less than fee", async () => {
			try {
				await this.contract.claim(tokenURI, {
					from: user1,
					value: "1",
				});
			} catch (error) {
				assert(
					error.message.includes(
						"NftGenerator: Claim fee must be equal to 0.05 ether"
					)
				);
				return;
			}
			assert(false);
		});
	});
});
