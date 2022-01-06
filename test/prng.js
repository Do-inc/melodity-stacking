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
    console.log(prng);

    const value = await prng.rotate();
    expect(value).to.be.bignumber.not.equal(0);
    expect(await prng.seed()).to.equals(1);
    expect(await prng.rotate()).to.be.bignumber.not.equal(value);
    expect(await prng.seed()).to.equals(2);
    expect(await prng.rotate()).to.be.bignumber.not.equal(value);
    expect(await prng.seed()).to.equals(3);
  });
});
