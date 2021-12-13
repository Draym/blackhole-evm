const fs = require('fs').promises;
const currentVersion = "v1";
let network = "development";

let path = `deployed/${currentVersion}/${network}`;

const migrate = async function () {
    await fs.mkdir(path, {recursive: true}, (err) => {
    });

    await fs.copyFile("build/contracts/EnergyShock.json", `${path}/EnergyShock.json`);
    await fs.copyFile("build/contracts/LifeEssence.json", `${path}/LifeEssence.json`);
    await fs.copyFile("build/contracts/PotionEssence.json", `${path}/PotionEssence.json`);
    await fs.copyFile("build/contracts/Uxonium.json", `${path}/Uxonium.json`);
    await fs.copyFile("build/contracts/DarkMatter.json", `${path}/DarkMatter.json`);
    await fs.copyFile("build/contracts/PlasmaEnergy.json", `${path}/PlasmaEnergy.json`);
    await fs.copyFile("build/contracts/VoidEssence.json", `${path}/VoidEssence.json`);
    await fs.copyFile("build/contracts/LegendaryCore.json", `${path}/LegendaryCore.json`);
    await fs.copyFile("build/contracts/HolyCore.json", `${path}/HolyCore.json`);
    await fs.copyFile("build/contracts/StarterPack.json", `${path}/StarterPack.json`);
    await fs.copyFile("build/contracts/CraftsmanProfile.json", `${path}/CraftsmanProfile.json`);
    await fs.copyFile("build/contracts/NokaiTechnique.json", `${path}/NokaiTechnique.json`);
    await fs.copyFile("build/contracts/NokaiStats.json", `${path}/NokaiStats.json`);
    await fs.copyFile("build/contracts/Nokai.json", `${path}/Nokai.json`);
    await fs.copyFile("build/contracts/BattleLogic.json", `${path}/BattleLogic.json`);
    await fs.copyFile("build/contracts/BlackHole.json", `${path}/BlackHole.json`);
    await fs.copyFile("build/contracts/CraftManager.json", `${path}/CraftManager.json`);
    await fs.copyFile("build/contracts/GameManager.json", `${path}/GameManager.json`);
    await fs.copyFile("build/contracts/Inventory.json", `${path}/Inventory.json`);
    await fs.copyFile("build/contracts/NokaiGacha.json", `${path}/NokaiGacha.json`);
}

migrate()