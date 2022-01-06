const chai = require("chai");
chai.use(require("chai-bignumber")());
const { expect } = chai;
const { ethers } = require("hardhat");

const deployPRNG = async () => {
  const PRNG = await ethers.getContractFactory("PRNG");
  const prng = await PRNG.deploy();
  return await prng.deployed();
};

describe("PRNG", function () {
  it("should rotate", async function () {
    let prng = await deployPRNG();

    let tx = await prng.rotate();
    await tx.wait();
    let seed = await prng.seed();

    const first_value = tx.value;
    
    expect(tx.value).to.be.bignumber.not.equal(0);
    expect(seed).to.equals(1);

    tx = await prng.rotate();
    await tx.wait();
    seed = await prng.seed();

    expect(tx.value).to.be.bignumber.not.equal(first_value);
    expect(seed).to.equals(2);

    tx = await prng.rotate();
    await tx.wait();
    seed = await prng.seed();
    
    expect(tx.value).to.be.bignumber.not.equal(first_value);
    expect(seed).to.equals(3);
  });
});
