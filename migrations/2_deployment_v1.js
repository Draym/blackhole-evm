/** Characters */
const Nokai = artifacts.require('Nokai')
const NokaiStats = artifacts.require('NokaiStats')
const NokaiTechnique = artifacts.require('NokaiTechnique')
/** Game management */
const BattleLogic = artifacts.require('BattleLogic')
const BlackHole = artifacts.require('BlackHole')
const CraftManager = artifacts.require('CraftManager')
const GameManager = artifacts.require('GameManager')
const Inventory = artifacts.require('Inventory')
/** Tokenomics */
const NokaiGacha = artifacts.require('NokaiGacha')
/** Tokens */
const EnergyShock = artifacts.require('EnergyShock')
const LifeEssence = artifacts.require('LifeEssence')
const PotionEssence = artifacts.require('PotionEssence')
const DarkEnergy = artifacts.require('DarkEnergy')
const DarkMatter = artifacts.require('DarkMatter')
const PlasmaEnergy = artifacts.require('PlasmaEnergy')
const VoidEssence = artifacts.require('VoidEssence')
const HolyArtefact = artifacts.require('HolyArtefact')
const HolyCore = artifacts.require('HolyCore')
const StarterPack = artifacts.require('StarterPack')

const fs = require('fs').promises;

const currentVersion = "v1";

module.exports = async function (deployer, network, accounts) {

    let deployed = {}

    /** TOKENS */
    await deployer.deploy(EnergyShock)
    let energyShock = await EnergyShock.deployed()
    console.log("EnergyShock: " + energyShock.address)
    deployed.energyShock = energyShock.address

    await deployer.deploy(LifeEssence)
    let lifeEssence = await LifeEssence.deployed()
    console.log("LifeEssence: " + lifeEssence.address)
    deployed.lifeEssence = lifeEssence.address

    await deployer.deploy(PotionEssence)
    let potionEssence = await PotionEssence.deployed()
    console.log("PotionEssence: " + potionEssence.address)
    deployed.potionEssence = potionEssence.address

    await deployer.deploy(DarkEnergy)
    let darkEnergy = await DarkEnergy.deployed()
    console.log("DarkEnergy: " + darkEnergy.address)
    deployed.darkEnergy = darkEnergy.address

    await deployer.deploy(DarkMatter)
    let darkMatter = await DarkMatter.deployed()
    console.log("DarkMatter: " + darkMatter.address)
    deployed.darkMatter = darkMatter.address

    await deployer.deploy(PlasmaEnergy)
    let plasmaEnergy = await PlasmaEnergy.deployed()
    console.log("PlasmaEnergy: " + plasmaEnergy.address)
    deployed.plasmaEnergy = plasmaEnergy.address

    await deployer.deploy(VoidEssence)
    let voidEssence = await VoidEssence.deployed()
    console.log("VoidEssence: " + voidEssence.address)
    deployed.voidEssence = voidEssence.address

    await deployer.deploy(HolyArtefact)
    let holyArtefact = await HolyArtefact.deployed()
    console.log("HolyArtefact: " + holyArtefact.address)
    deployed.holyArtefact = holyArtefact.address

    await deployer.deploy(HolyCore)
    let holyCore = await HolyCore.deployed()
    console.log("HolyCore: " + holyCore.address)
    deployed.holyCore = holyCore.address

    await deployer.deploy(StarterPack)
    let starterPack = await StarterPack.deployed()
    console.log("StarterPack: " + starterPack.address)
    deployed.starterPack = starterPack.address

    /** Characters */
    await deployer.deploy(NokaiTechnique)
    let nokaiTechnique = await NokaiTechnique.deployed()
    console.log("NokaiTechnique: " + nokaiTechnique.address)
    deployed.nokaiTechnique = nokaiTechnique.address

    await deployer.deploy(NokaiStats, nokaiTechnique.address)
    let nokaiStats = await NokaiStats.deployed()
    console.log("NokaiStats: " + nokaiStats.address)
    deployed.nokaiStats = nokaiStats.address

    await deployer.deploy(Nokai, nokaiStats.address, "")
    let nokai = await Nokai.deployed()
    console.log("Nokai: " + nokai.address)
    deployed.nokai = nokai.address

    /** Game management */
    await deployer.deploy(BattleLogic)
    let battleLogic = await BattleLogic.deployed()
    console.log("BattleLogic: " + battleLogic.address)
    deployed.battleLogic = battleLogic.address

    await deployer.deploy(BlackHole, 200, 200)
    let blackHole = await BlackHole.deployed()
    console.log("BlackHole: " + blackHole.address)
    deployed.blackHole = blackHole.address

    await deployer.deploy(CraftManager, holyCore.address, holyArtefact.address, potionEssence.address, lifeEssence.address, energyShock.address, darkEnergy.address, darkMatter.address, plasmaEnergy.address, voidEssence.address)
    let craftManager = await CraftManager.deployed()
    console.log("CraftManager: " + craftManager.address)
    deployed.craftManager = craftManager.address

    await deployer.deploy(GameManager, blackHole.address, nokai.address, nokaiStats.address, battleLogic.address, darkEnergy.address, darkMatter.address, plasmaEnergy.address, voidEssence.address)
    let gameManager = await GameManager.deployed()
    console.log("GameManager: " + gameManager.address)
    deployed.gameManager = gameManager.address

    await deployer.deploy(Inventory, nokaiStats.address, potionEssence.address, lifeEssence.address, energyShock.address)
    let inventory = await Inventory.deployed()
    console.log("Inventory: " + inventory.address)
    deployed.inventory = inventory.address

    /** Tokenomics */
    await deployer.deploy(NokaiGacha, nokai.address, holyCore.address, holyArtefact.address)
    let nokaiGacha = await NokaiGacha.deployed()
    console.log("NokaiGacha: " + nokaiGacha.address)
    deployed.nokaiGacha = nokaiGacha.address

    await fs.writeFile(`deployed/${currentVersion}/result.json`, JSON.stringify(deployed))
};
