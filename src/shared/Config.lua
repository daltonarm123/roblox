local Config = {}

Config.DATASTORE_NAME = "JunkyardEmpire_PlayerData_v1"
Config.AUTOSAVE_INTERVAL = 60
Config.PASSIVE_TICK = 2
Config.STARTING_CASH = 250
Config.STARTING_CAPACITY = 25
Config.REBIRTH_BASE_REQUIREMENT = 25000
Config.REBIRTH_GROWTH = 2
Config.REBIRTH_MULTIPLIER = 0.25

Config.UPGRADES = {
    PickupPower = {
        DisplayName = "Pickup Power",
        BaseCost = 100,
        CostGrowth = 1.55,
        MaxLevel = 15,
    },
    SellBoost = {
        DisplayName = "Scrap Value",
        BaseCost = 250,
        CostGrowth = 1.6,
        MaxLevel = 20,
    },
    Storage = {
        DisplayName = "Storage",
        BaseCost = 175,
        CostGrowth = 1.5,
        MaxLevel = 15,
    },
    AutoCrusher = {
        DisplayName = "Auto Crusher",
        BaseCost = 500,
        CostGrowth = 1.7,
        MaxLevel = 25,
    },
}

Config.MONETIZATION = {
    -- Replace these zeroes after creating the products/passes in Creator Dashboard.
    GamePasses = {
        DoubleCash = 0,
        VIP = 0,
    },
    DeveloperProducts = {
        Cash5000 = 0,
        Cash50000 = 0,
    },
}

function Config.GetUpgradeCost(upgradeName, currentLevel)
    local upgrade = Config.UPGRADES[upgradeName]
    if not upgrade then
        return math.huge
    end

    return math.floor(upgrade.BaseCost * (upgrade.CostGrowth ^ currentLevel))
end

function Config.GetCapacity(storageLevel)
    return Config.STARTING_CAPACITY + (storageLevel * 25)
end

function Config.GetRebirthRequirement(rebirths)
    return math.floor(Config.REBIRTH_BASE_REQUIREMENT * (Config.REBIRTH_GROWTH ^ rebirths))
end

function Config.GetRebirthMultiplier(rebirths)
    return 1 + (rebirths * Config.REBIRTH_MULTIPLIER)
end

return Config
