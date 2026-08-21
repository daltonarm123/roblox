local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.DataService)

local EconomyService = {}

local function getCashMultiplier(player, data)
    local passMultiplier = tonumber(player:GetAttribute("CashMultiplier")) or 1
    return passMultiplier * Config.GetRebirthMultiplier(data.Rebirths)
end

function EconomyService.GetState(player)
    local data = DataService.Get(player)
    if not data then
        return nil
    end

    local upgrades = {}
    local nextUpgradeCosts = {}
    for name, definition in pairs(Config.UPGRADES) do
        local level = data.Upgrades[name] or 0
        upgrades[name] = level
        nextUpgradeCosts[name] = level >= definition.MaxLevel and -1 or Config.GetUpgradeCost(name, level)
    end

    return {
        Cash = data.Cash,
        Scrap = data.Scrap,
        Capacity = Config.GetCapacity(data.Upgrades.Storage or 0),
        LifetimeCash = data.LifetimeCash,
        Rebirths = data.Rebirths,
        RebirthRequirement = Config.GetRebirthRequirement(data.Rebirths),
        Upgrades = upgrades,
        NextUpgradeCosts = nextUpgradeCosts,
        PassivePerTick = EconomyService.GetPassiveIncome(player),
    }
end

function EconomyService.CollectScrap(player)
    local data = DataService.Get(player)
    if not data then
        return false, "Data not loaded"
    end

    local capacity = Config.GetCapacity(data.Upgrades.Storage or 0)
    if data.Scrap >= capacity then
        return false, "Storage full - sell your scrap"
    end

    local pickupLevel = data.Upgrades.PickupPower or 0
    local amount = 1 + (pickupLevel * 2)
    local added = DataService.AddScrap(player, amount, capacity)

    if added <= 0 then
        return false, "Storage full - sell your scrap"
    end

    return true, string.format("+%d scrap", added)
end

function EconomyService.SellScrap(player)
    local data = DataService.Get(player)
    if not data then
        return false, "Data not loaded"
    end

    if data.Scrap <= 0 then
        return false, "No scrap to sell"
    end

    local scrap = DataService.ClearScrap(player)
    local sellLevel = data.Upgrades.SellBoost or 0
    local valuePerScrap = 10 * (1 + (sellLevel * 0.25))
    local payout = math.floor(scrap * valuePerScrap * getCashMultiplier(player, data))
    DataService.AddCash(player, payout)

    return true, string.format("Sold %d scrap for $%d", scrap, payout)
end

function EconomyService.BuyUpgrade(player, upgradeName)
    local data = DataService.Get(player)
    local definition = Config.UPGRADES[upgradeName]
    if not data or not definition then
        return false, "Invalid upgrade"
    end

    local currentLevel = data.Upgrades[upgradeName] or 0
    if currentLevel >= definition.MaxLevel then
        return false, "Upgrade is maxed"
    end

    local cost = Config.GetUpgradeCost(upgradeName, currentLevel)
    if not DataService.SpendCash(player, cost) then
        return false, string.format("Need $%d", cost)
    end

    data.Upgrades[upgradeName] = currentLevel + 1
    return true, string.format("%s upgraded to Lv.%d", definition.DisplayName, currentLevel + 1)
end

function EconomyService.TryRebirth(player)
    local data = DataService.Get(player)
    if not data then
        return false, "Data not loaded"
    end

    local requirement = Config.GetRebirthRequirement(data.Rebirths)
    if data.Cash < requirement then
        return false, string.format("Need $%d to rebirth", requirement)
    end

    DataService.ResetForRebirth(player)
    return true, string.format("Rebirth complete! Permanent cash multiplier is now x%.2f", Config.GetRebirthMultiplier(data.Rebirths))
end

function EconomyService.GetPassiveIncome(player)
    local data = DataService.Get(player)
    if not data then
        return 0
    end

    local level = data.Upgrades.AutoCrusher or 0
    if level <= 0 then
        return 0
    end

    local baseIncome = 5 * level * (1 + ((level - 1) * 0.12))
    return math.max(1, math.floor(baseIncome * getCashMultiplier(player, data)))
end

function EconomyService.PayPassiveIncome(player)
    local amount = EconomyService.GetPassiveIncome(player)
    if amount > 0 then
        DataService.AddCash(player, amount)
    end
    return amount
end

return EconomyService
