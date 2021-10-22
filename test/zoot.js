const { expect } = require("chai");
const { artifacts } = require("hardhat");
const Zoot = artifacts.require("Zoot");

contract("Zoot", async ([deployer, user1, user2]) => {
	beforeEach(async () => {
		this.contract = await Zoot.new({ from: deployer });
	});

	describe("deployment", () => {
		it("should deploy contract properly", async () => {
			expect(this.contract.address).not.null;
			expect(this.contract.address).not.undefined;
			expect(this.contract.address).not.equal("");
		});

		it("should set name properly", async () => {
			expect(await this.contract.name()).to.equal("ZOOT");
		});

		it("should set symbol properly", async () => {
			expect(await this.contract.symbol()).to.equal("ZOOT");
		});
	});

	describe("mint function", () => {
		beforeEach(async () => {
			await this.contract.mint({
				from: user1,
			});

			await this.contract.mint({
				from: user2,
			});
		});

		it("should mint NFT properly", async () => {
			const _word = await this.contract.wordLists("0");
			console.log("word", _word);

			console.log(await this.contract.tokenURI("0"));
			expect(_word).not.null;
			expect(_word).not.equal("");
			expect(await this.contract.ownerOf("0")).to.equal(user1);
		});

		it("should mint NFT properly to owner address", async () => {
			expect(await this.contract.ownerOf("1")).to.equal(user2);
		});
	});
});
