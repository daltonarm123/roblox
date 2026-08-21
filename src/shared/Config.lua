local Config = {}

Config.GameName = "CONTAINMENT HEIST"
Config.DataStoreName = "ContainmentHeist_PlayerData_v1"
Config.AutosaveSeconds = 60
Config.OfflineIncomeCapSeconds = 8 * 60 * 60
Config.BaseCount = 6
Config.StartingCapacity = 3
Config.MaxCapacity = 6
Config.CentralSpawnCount = 6
Config.SpecimenRespawnSeconds = 10
Config.RareEventSeconds = 5 * 60
Config.RaidGraceSeconds = 45

Config.SpeedUpgrade = {
    BaseCost = 250,
    Growth = 1.75,
    MaxLevel = 20,
    WalkSpeedBase = 16,
    WalkSpeedPerLevel = 1.15,
}

Config.CapacityUpgrade = {
    BaseCost = 1800,
    Growth = 3.25,
    MaxLevel = Config.MaxCapacity - Config.StartingCapacity,
}

Config.Specimens = {
    { Id = "Gel01", Name = "Gel-01", Rarity = "Common", Income = 8, Weight = 34, Shape = "Ball", Color = Color3.fromRGB(72, 255, 145) },
    { Id = "Watcher", Name = "The Watcher", Rarity = "Common", Income = 11, Weight = 28, Shape = "Ball", Color = Color3.fromRGB(255, 244, 214) },
    { Id = "Mimic", Name = "Mimic Cube", Rarity = "Uncommon", Income = 22, Weight = 19, Shape = "Block", Color = Color3.fromRGB(180, 105, 255) },
    { Id = "PulseCore", Name = "Pulse Core", Rarity = "Rare", Income = 55, Weight = 11, Shape = "Ball", Color = Color3.fromRGB(85, 190, 255) },
    { Id = "VoidSeed", Name = "Void Seed", Rarity = "Epic", Income = 140, Weight = 6, Shape = "Ball", Color = Color3.fromRGB(75, 38, 110) },
    { Id = "StarParasite", Name = "Star Parasite", Rarity = "Legendary", Income = 420, Weight = 2, Shape = "Ball", Color = Color3.fromRGB(255, 205, 66) },
}

Config.Variants = {
    { Id = "Normal", Name = "Normal", Multiplier = 1, Weight = 76 },
    { Id = "Glowing", Name = "Glowing", Multiplier = 1.5, Weight = 16 },
    { Id = "Radioactive", Name = "Radioactive", Multiplier = 2.5, Weight = 6 },
    { Id = "Void", Name = "Void", Multiplier = 5, Weight = 2 },
}

function Config.GetSpeedCost(level)
    return math.floor(Config.SpeedUpgrade.BaseCost * (Config.SpeedUpgrade.Growth ^ level))
end

function Config.GetCapacityCost(level)
    return math.floor(Config.CapacityUpgrade.BaseCost * (Config.CapacityUpgrade.Growth ^ level))
end

function Config.GetCapacity(level)
    return math.clamp(Config.StartingCapacity + level, Config.StartingCapacity, Config.MaxCapacity)
end

function Config.GetWalkSpeed(level)
    return Config.SpeedUpgrade.WalkSpeedBase + (Config.SpeedUpgrade.WalkSpeedPerLevel * level)
end

function Config.GetSpecimenById(id)
    for _, specimen in ipairs(Config.Specimens) do
        if specimen.Id == id then
            return specimen
        end
    end
end

function Config.GetVariantById(id)
    for _, variant in ipairs(Config.Variants) do
        if variant.Id == id then
            return variant
        end
    end
end

return Config
