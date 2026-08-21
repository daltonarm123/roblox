local RunService = game:GetService("RunService")

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
Config.RareEventSeconds = RunService:IsStudio() and 60 or (5 * 60)
Config.RaidGraceSeconds = 45

-- Lab defense systems.
Config.EmergencyShieldDuration = 60
Config.EmergencyShieldBaseCooldown = 5 * 60
Config.EmergencyShieldCooldownReductionPerLevel = 20
Config.LockdownMaxSeconds = 3 * 60
Config.LockdownCooldownSeconds = 60 * 60

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

Config.IncomeUpgrade = {
    BaseCost = 2500,
    Growth = 1.85,
    MaxLevel = 10,
    BonusPerLevel = 0.10,
}

Config.ShieldTechUpgrade = {
    BaseCost = 4000,
    Growth = 2,
    MaxLevel = 5,
}

-- Fun abilities are intentionally short-lived and have meaningful cooldowns.
-- Cloak is disabled while carrying loot so paid/earned uses do not become pay-to-win.
Config.Abilities = {
    StaticBurst = {
        Name = "STATIC BURST",
        Description = "Scrambles every rival's screen for 2 seconds.",
        ResearchCost = 1800,
        Cooldown = 45,
        Duration = 2.0,
        RobuxPrice = 15,
    },
    JumpScare = {
        Name = "BREACH SCARE",
        Description = "Triggers a quick anomaly scare on every rival.",
        ResearchCost = 3200,
        Cooldown = 75,
        Duration = 1.4,
        RobuxPrice = 25,
    },
    Cloak = {
        Name = "PHASE CLOAK",
        Description = "Become hard to see for 15 seconds. Cancels if you carry loot.",
        ResearchCost = 5000,
        Cooldown = 120,
        Duration = 15,
        RobuxPrice = 29,
    },
}

-- First season. We can change the ID to reset progression for the next season.
Config.Season = {
    Id = "S1",
    Name = "CONTAINMENT PROTOCOL",
    MaxTier = 20,
    XPPerTier = 100,
    SuggestedPremiumPrice = 299,
    Missions = {
        { Id = "PlaySeconds", Name = "Stay in containment for 10 minutes", Target = 10 * 60, XP = 60 },
        { Id = "ResearchEarned", Name = "Earn 2,500 Research", Target = 2500, XP = 70 },
        { Id = "Contained", Name = "Contain 3 anomalies", Target = 3, XP = 80 },
        { Id = "Shields", Name = "Activate your emergency shield", Target = 1, XP = 40 },
    },
}

-- Replace these zeroes after the experience is published and the products are
-- created in Creator Dashboard. Zero IDs are intentionally safe/no-purchase.
Config.Monetization = {
    GamePasses = {
        DoubleResearch = 0,
        VIP = 0,
    },
    DeveloperProducts = {
        Research5000 = 0,
        Research25000 = 0,
        InstantShieldRecharge = 0,
        SeasonPremium = 0,
        StaticBurstCharge = 0,
        JumpScareCharge = 0,
        CloakCharge = 0,
    },
    SuggestedPrices = {
        DoubleResearch = 399,
        VIP = 199,
        Research5000 = 29,
        Research25000 = 99,
        InstantShieldRecharge = 19,
        SeasonPremium = 299,
        StaticBurstCharge = 15,
        JumpScareCharge = 25,
        CloakCharge = 29,
    },
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

function Config.GetIncomeUpgradeCost(level)
    return math.floor(Config.IncomeUpgrade.BaseCost * (Config.IncomeUpgrade.Growth ^ level))
end

function Config.GetShieldTechCost(level)
    return math.floor(Config.ShieldTechUpgrade.BaseCost * (Config.ShieldTechUpgrade.Growth ^ level))
end

function Config.GetCapacity(level)
    return math.clamp(Config.StartingCapacity + level, Config.StartingCapacity, Config.MaxCapacity)
end

function Config.GetWalkSpeed(level)
    return Config.SpeedUpgrade.WalkSpeedBase + (Config.SpeedUpgrade.WalkSpeedPerLevel * level)
end

function Config.GetIncomeMultiplier(level)
    return 1 + (math.clamp(level or 0, 0, Config.IncomeUpgrade.MaxLevel) * Config.IncomeUpgrade.BonusPerLevel)
end

function Config.GetEmergencyShieldCooldown(level)
    local reduction = math.clamp(level or 0, 0, Config.ShieldTechUpgrade.MaxLevel) * Config.EmergencyShieldCooldownReductionPerLevel
    return math.max(60, Config.EmergencyShieldBaseCooldown - reduction)
end

function Config.GetSeasonReward(tier, premium)
    tier = math.clamp(math.floor(tier or 1), 1, Config.Season.MaxTier)
    local reward = {
        Research = premium and (900 + tier * 250) or (400 + tier * 150),
        Ability = nil,
        AbilityCount = 0,
    }

    if premium then
        if tier % 4 == 0 then
            reward.Ability = "Cloak"
            reward.AbilityCount = 1
        elseif tier % 3 == 0 then
            reward.Ability = "JumpScare"
            reward.AbilityCount = 1
        elseif tier % 2 == 0 then
            reward.Ability = "StaticBurst"
            reward.AbilityCount = 1
        end
    elseif tier % 5 == 0 then
        reward.Ability = "StaticBurst"
        reward.AbilityCount = 1
    end

    return reward
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
