const { expect } = require("chai");
const { ethers } = require("hardhat");

const deployMasterchef = async () => {
  const Masterchef = await ethers.getContractFactory("Masterchef");
  const masterchef = await Masterchef.deploy();
  return await masterchef.deployed();
};

const loadStackingPanda = async (address) => {
  const StackingPanda = await ethers.getContractFactory("StackingPanda");
  return await StackingPanda.attach(address);
};

describe("Masterchef", function () {
  let masterchef,
    null_address = `0x${"0".repeat(40)}`;

  beforeEach(async function () {
    [owner, acc_1, acc_2] = await ethers.getSigners();

    masterchef = await deployMasterchef();
  });
  it("should deploy contracts at startup", async function () {
    expect(await masterchef.stackingPanda()).to.not.equal(null_address);
  });
  it("should trigger nft minting", async function () {
    await masterchef.triggerMinting();

    let stacking_panda = await loadStackingPanda(
      await masterchef.stackingPanda()
    );

    expect(await stacking_panda.balanceOf(masterchef.address)).to.equals(1);
    expect(await stacking_panda.ownerOf(0)).to.equals(masterchef.address);

    let metadata = await stacking_panda.getMetadata(0);
    expect(metadata.name).to.equals("test");
    expect(metadata.picUrl).to.equals("url");
    expect(metadata.bonus.decimals).to.equals(18);
    expect(metadata.bonus.meldToMeld).to.equals(ethers.utils.parseEther("1.5"));
    expect(metadata.bonus.toMeld).to.equals(ethers.utils.parseEther("0.5"));
  });
});
