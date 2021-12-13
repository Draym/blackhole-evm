/** Characters */
const Nokai = artifacts.require('Nokai')
const NokaiStats = artifacts.require('NokaiStats')
const NokaiTechnique = artifacts.require('NokaiTechnique')
const CraftsmanProfile = artifacts.require('CraftsmanProfile')
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
const Uxonium = artifacts.require('Uxonium')
const DarkMatter = artifacts.require('DarkMatter')
const PlasmaEnergy = artifacts.require('PlasmaEnergy')
const VoidEssence = artifacts.require('VoidEssence')
const LegendCore = artifacts.require('LegendCore')
const HolyCore = artifacts.require('HolyCore')
const StarterPack = artifacts.require('StarterPack')

const fs = require('fs').promises;

const currentVersion = "v1";

module.exports = async function (deployer, network, accounts) {

    let deployed = {
        version: currentVersion,
        network: network
    }

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

    await deployer.deploy(Uxonium)
    let uxonium = await Uxonium.deployed()
    console.log("Uxonium: " + uxonium.address)
    deployed.uxonium = uxonium.address

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

    await deployer.deploy(LegendCore, "40000000000000000")
    let legendCore = await LegendCore.deployed()
    console.log("LegendCore: " + legendCore.address)
    deployed.legendCore = legendCore.address

    await deployer.deploy(HolyCore, "10000000000000000")
    let holyCore = await HolyCore.deployed()
    console.log("HolyCore: " + holyCore.address)
    deployed.holyCore = holyCore.address

    await deployer.deploy(StarterPack, "100000000000000000")
    let starterPack = await StarterPack.deployed()
    console.log("StarterPack: " + starterPack.address)
    deployed.starterPack = starterPack.address

    /** Characters */
    await deployer.deploy(CraftsmanProfile)
    let craftsmanProfile = await CraftsmanProfile.deployed()
    console.log("CraftsmanProfile: " + craftsmanProfile.address)
    deployed.craftsmanProfile = craftsmanProfile.address

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

    await deployer.deploy(BlackHole, "Neoverse", 10, 10)
    let blackHole = await BlackHole.deployed()
    console.log("BlackHole: " + blackHole.address)
    deployed.blackHole = blackHole.address

    await deployer.deploy(CraftManager, craftsmanProfile.address, holyCore.address, legendCore.address, potionEssence.address, lifeEssence.address, energyShock.address, uxonium.address, darkMatter.address, plasmaEnergy.address, voidEssence.address)
    let craftManager = await CraftManager.deployed()
    console.log("CraftManager: " + craftManager.address)
    deployed.craftManager = craftManager.address

    await deployer.deploy(GameManager, blackHole.address, nokai.address, nokaiStats.address, battleLogic.address, uxonium.address, darkMatter.address, plasmaEnergy.address, voidEssence.address)
    let gameManager = await GameManager.deployed()
    console.log("GameManager: " + gameManager.address)
    deployed.gameManager = gameManager.address

    await deployer.deploy(Inventory, nokaiStats.address, potionEssence.address, lifeEssence.address, energyShock.address)
    let inventory = await Inventory.deployed()
    console.log("Inventory: " + inventory.address)
    deployed.inventory = inventory.address

    /** Tokenomics */
    await deployer.deploy(NokaiGacha, nokai.address, holyCore.address, legendCore.address)
    let nokaiGacha = await NokaiGacha.deployed()
    console.log("NokaiGacha: " + nokaiGacha.address)
    deployed.nokaiGacha = nokaiGacha.address


    /** ROLES */
    await holyCore.grantRole(await holyCore.MINT_ROLE(), craftManager.address)
    await holyCore.grantRole(await holyCore.BURN_ROLE(), nokaiGacha.address)

    await legendCore.grantRole(await legendCore.MINT_ROLE(), craftManager.address)
    await legendCore.grantRole(await legendCore.BURN_ROLE(), nokaiGacha.address)

    await energyShock.grantRole(await energyShock.MINT_ROLE(), craftManager.address)
    await energyShock.grantRole(await energyShock.BURN_ROLE(), inventory.address)

    await lifeEssence.grantRole(await lifeEssence.MINT_ROLE(), craftManager.address)
    await lifeEssence.grantRole(await lifeEssence.BURN_ROLE(), inventory.address)

    await potionEssence.grantRole(await potionEssence.MINT_ROLE(), craftManager.address)
    await potionEssence.grantRole(await potionEssence.BURN_ROLE(), inventory.address)

    await uxonium.grantRole(await potionEssence.BURN_ROLE(), craftManager.address)
    await uxonium.grantRole(await potionEssence.MINT_ROLE(), gameManager.address)

    await darkMatter.grantRole(await potionEssence.BURN_ROLE(), craftManager.address)
    await darkMatter.grantRole(await potionEssence.MINT_ROLE(), gameManager.address)
    await darkMatter.grantRole(await potionEssence.BURN_ROLE(), gameManager.address)

    await plasmaEnergy.grantRole(await potionEssence.BURN_ROLE(), craftManager.address)
    await plasmaEnergy.grantRole(await potionEssence.MINT_ROLE(), gameManager.address)
    await plasmaEnergy.grantRole(await potionEssence.BURN_ROLE(), gameManager.address)

    await voidEssence.grantRole(await potionEssence.BURN_ROLE(), craftManager.address)
    await voidEssence.grantRole(await potionEssence.MINT_ROLE(), gameManager.address)

    await starterPack.grantRole(await starterPack.BURN_ROLE(), nokaiGacha.address)

    await nokai.grantRole(await nokai.MINT_ROLE(), nokaiGacha.address)

    await nokaiStats.grantRole(await nokaiStats.NOKAI_MANAGER_ROLE(), nokai.address)
    await nokaiStats.grantRole(await nokaiStats.GAME_MANAGER_ROLE(), gameManager.address)
    await nokaiStats.grantRole(await nokaiStats.INVENTORY_MANAGER_ROLE(), inventory.address)

    await craftsmanProfile.grantRole(await craftsmanProfile.CRAFT_MANAGER_ROLE(), craftManager.address)

    await blackHole.grantRole(await blackHole.GAME_MANAGER_ROLE(), gameManager.address)

    /** SETUP */
    await nokai.setup(10)

    let path = `deployed/${currentVersion}/${network}`;
    await fs.mkdir(path, {recursive: true}, (err) => {
    });

    await fs.writeFile(`${path}/result.json`, JSON.stringify(deployed))
}