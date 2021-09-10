const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

const toWei = (_amount) => ethers.utils.parseEther(_amount.toString());
const fromWei = (_amount) => ethers.utils.formatEther(_amount.toString());

describe("NameGenerator", async () => {
	let deployer, user1, user2, user3;
	let Fee;

	beforeEach(async () => {
		const NameGenerator = await ethers.getContractFactory("NameGenerator");

		[deployer, user1, user2, user3] = await ethers.getSigners();

		this.contract = await NameGenerator.deploy();
		Fee = await this.contract.Fee();
	});

	describe("deployment", () => {
		it("should deploy contract properly", async () => {
			expect(this.contract.address).not.null;
			expect(this.contract.address).not.undefined;
			expect(this.contract.address).not.equal("");
		});

		it("should set name properly", async () => {
			expect(await this.contract.name()).to.equal("Name-Generator");
		});

		it("should set symbol properly", async () => {
			expect(await this.contract.symbol()).to.equal("N-GEN");
		});

		it("should set fee properly", async () => {
			expect(fromWei(Fee)).to.equal("0.05");
		});
	});

	describe("random()", () => {
		it("should generate a random function", async () => {
			expect(await this.contract.random()).not.null;
			expect(await this.contract.random()).not.undefined;
			expect(await this.contract.random()).not.equal("");
		});
	});

	describe("mint()", () => {
		beforeEach(async () => {
			await this.contract.connect(user1).mint({ value: Fee });
		});

		it("should mint new random name", async () => {
			const _generatedName = await this.contract.names("0");
			expect(_generatedName).not.null;
			expect(_generatedName).not.undefined;
			expect(_generatedName).not.equal("");
		});

		it("should reject if payment is less than minting fee", async () => {
			try {
				await this.contract.connect(user1).mint({ value: "0" });
			} catch (error) {
				assert(
					error
						.toString()
						.includes("NftGenerator: mint fee must be equal to 0.05 ether")
				);
			}
		});

		it("should mint name to sender address", async () => {
			expect(await this.contract.ownerOf("0")).to.equal(user1.address);
		});
	});

	describe("tokenURI()", () => {
		beforeEach(async () => {
			await this.contract.connect(user1).mint({ value: Fee });
		});

		it("should return tokenURI for a specific tokenId", async () => {
			expect(await this.contract.tokenURI("0")).not.null;
			expect(await this.contract.tokenURI("0")).not.undefined;
			expect(await this.contract.tokenURI("0")).not.equal("");
		});
	});
});
