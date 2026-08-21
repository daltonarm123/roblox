local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)

local DataService = {}
DataService.__index = DataService

-- Unpublished Studio places cannot access DataStoreService. Keep the game fully
-- playable with temporary in-memory profiles until the experience is published.
local store = nil
local dataStoreAvailable = false

if game.GameId ~= 0 then
    local ok, result = pcall(function()
        return DataStoreService:GetDataStore(Config.DataStoreName)
    end)
    if ok then
        store = result
        dataStoreAvailable = true
    else
        warn("ContainmentHeist could not initialize DataStore; using temporary session data:", result)
    end
elseif RunService:IsStudio() then
    print("ContainmentHeist: unpublished Studio test detected; using temporary session data.")
end

local profiles = {}

local DEFAULT = {
    Research = 0,
    SpeedLevel = 0,
    CapacityLevel = 0,
    IncomeLevel = 0,
    ShieldLevel = 0,
    Prestige = 0,
    Specimens = {},
    ShieldReadyAt = 0,
    LockdownReadyAt = 0,
    LastSeen = 0,

    SeasonId = Config.Season.Id,
    SeasonXP = 0,
    SeasonFreeClaimed = 0,
    SeasonPremiumClaimed = 0,
    PremiumSeasonId = "",
    DailyMissionDay = 0,
    DailyProgress = {
        PlaySeconds = 0,
        ResearchEarned = 0,
        Contained = 0,
        Shields = 0,
    },
    DailyCompleted = {},
    AbilityCharges = {
        StaticBurst = 0,
        JumpScare = 0,
        Cloak = 0,
    },
}

local function clone(value)
    if type(value) ~= "table" then
        return value
    end
    local out = {}
    for key, child in pairs(value) do
        out[key] = clone(child)
    end
    return out
end

local function currentDay()
    return math.floor(os.time() / 86400)
end

local function resetDaily(profile)
    profile.DailyMissionDay = currentDay()
    profile.DailyProgress = {
        PlaySeconds = 0,
        ResearchEarned = 0,
        Contained = 0,
        Shields = 0,
    }
    profile.DailyCompleted = {}
end

local function ensureSeason(profile)
    if profile.SeasonId ~= Config.Season.Id then
        profile.SeasonId = Config.Season.Id
        profile.SeasonXP = 0
        profile.SeasonFreeClaimed = 0
        profile.SeasonPremiumClaimed = 0
        resetDaily(profile)
    end

    if profile.DailyMissionDay ~= currentDay() then
        resetDaily(profile)
    end
end

local function reconcile(data)
    local result = clone(DEFAULT)
    if type(data) == "table" then
        for key, defaultValue in pairs(DEFAULT) do
            local incoming = data[key]
            if type(defaultValue) == "table" then
                if type(incoming) == "table" then
                    result[key] = clone(incoming)
                end
            elseif type(incoming) == type(defaultValue) then
                result[key] = incoming
            end
        end
    end

    result.SpeedLevel = math.clamp(result.SpeedLevel, 0, Config.SpeedUpgrade.MaxLevel)
    result.CapacityLevel = math.clamp(result.CapacityLevel, 0, Config.CapacityUpgrade.MaxLevel)
    result.IncomeLevel = math.clamp(result.IncomeLevel, 0, Config.IncomeUpgrade.MaxLevel)
    result.ShieldLevel = math.clamp(result.ShieldLevel, 0, Config.ShieldTechUpgrade.MaxLevel)
    result.SeasonXP = math.max(0, math.floor(result.SeasonXP or 0))
    result.SeasonFreeClaimed = math.max(0, math.floor(result.SeasonFreeClaimed or 0))
    result.SeasonPremiumClaimed = math.max(0, math.floor(result.SeasonPremiumClaimed or 0))

    result.AbilityCharges = result.AbilityCharges or {}
    for abilityId in pairs(Config.Abilities) do
        result.AbilityCharges[abilityId] = math.max(0, math.floor(result.AbilityCharges[abilityId] or 0))
    end

    result.DailyProgress = result.DailyProgress or {}
    for _, mission in ipairs(Config.Season.Missions) do
        result.DailyProgress[mission.Id] = math.max(0, math.floor(result.DailyProgress[mission.Id] or 0))
    end
    result.DailyCompleted = result.DailyCompleted or {}

    ensureSeason(result)
    return result
end

local function specimenIncome(profile)
    local total = 0
    for _, owned in ipairs(profile.Specimens) do
        local specimen = Config.GetSpecimenById(owned.SpecimenId)
        local variant = Config.GetVariantById(owned.VariantId)
        if specimen and variant then
            total += specimen.Income * variant.Multiplier
        end
    end
    local prestigeMultiplier = 1 + (profile.Prestige * 0.15)
    local shopMultiplier = Config.GetIncomeMultiplier(profile.IncomeLevel)
    return math.floor(total * prestigeMultiplier * shopMultiplier)
end

function DataService.Load(player)
    local data

    if dataStoreAvailable and store then
        local ok, err = pcall(function()
            data = store:GetAsync(tostring(player.UserId))
        end)
        if not ok then
            warn("ContainmentHeist DataStore load failed for", player.UserId, err)
        end
    end

    local profile = reconcile(data)
    local now = os.time()
    if profile.LastSeen > 0 then
        local elapsed = math.clamp(now - profile.LastSeen, 0, Config.OfflineIncomeCapSeconds)
        local income = specimenIncome(profile)
        profile.OfflineAward = math.floor(elapsed * income)
        profile.Research += profile.OfflineAward
    else
        profile.OfflineAward = 0
    end
    profile.LastSeen = now
    profiles[player.UserId] = profile
    return profile
end

function DataService.Get(player)
    return profiles[player.UserId]
end

function DataService.EnsureDaily(player)
    local profile = profiles[player.UserId]
    if not profile then return nil end
    ensureSeason(profile)
    return profile
end

function DataService.GetIncome(player)
    local profile = profiles[player.UserId]
    if not profile then return 0 end
    local income = specimenIncome(profile)
    if player:GetAttribute("DoubleResearch") then
        income *= 2
    end
    return math.floor(income)
end

function DataService.AddResearch(player, amount)
    local profile = profiles[player.UserId]
    if not profile then return false end
    profile.Research = math.max(0, math.floor(profile.Research + amount))
    return true
end

function DataService.SpendResearch(player, amount)
    local profile = profiles[player.UserId]
    if not profile or amount < 0 or profile.Research < amount then
        return false
    end
    profile.Research -= amount
    return true
end

function DataService.AddSpecimen(player, specimenId, variantId)
    local profile = profiles[player.UserId]
    if not profile then return false end
    local capacity = Config.GetCapacity(profile.CapacityLevel)
    if #profile.Specimens >= capacity then
        return false
    end
    table.insert(profile.Specimens, {
        SpecimenId = specimenId,
        VariantId = variantId,
        CapturedAt = os.time(),
    })
    return true
end

function DataService.RemoveSpecimenAt(player, index)
    local profile = profiles[player.UserId]
    if not profile or not profile.Specimens[index] then
        return nil
    end
    return table.remove(profile.Specimens, index)
end

function DataService.BuySpeed(player)
    local profile = profiles[player.UserId]
    if not profile or profile.SpeedLevel >= Config.SpeedUpgrade.MaxLevel then
        return false, "MAX"
    end
    local cost = Config.GetSpeedCost(profile.SpeedLevel)
    if not DataService.SpendResearch(player, cost) then
        return false, "NOT_ENOUGH"
    end
    profile.SpeedLevel += 1
    return true
end

function DataService.BuyCapacity(player)
    local profile = profiles[player.UserId]
    if not profile or profile.CapacityLevel >= Config.CapacityUpgrade.MaxLevel then
        return false, "MAX"
    end
    local cost = Config.GetCapacityCost(profile.CapacityLevel)
    if not DataService.SpendResearch(player, cost) then
        return false, "NOT_ENOUGH"
    end
    profile.CapacityLevel += 1
    return true
end

function DataService.BuyIncomeBoost(player)
    local profile = profiles[player.UserId]
    if not profile or profile.IncomeLevel >= Config.IncomeUpgrade.MaxLevel then
        return false, "MAX"
    end
    local cost = Config.GetIncomeUpgradeCost(profile.IncomeLevel)
    if not DataService.SpendResearch(player, cost) then
        return false, "NOT_ENOUGH"
    end
    profile.IncomeLevel += 1
    return true
end

function DataService.BuyShieldTech(player)
    local profile = profiles[player.UserId]
    if not profile or profile.ShieldLevel >= Config.ShieldTechUpgrade.MaxLevel then
        return false, "MAX"
    end
    local cost = Config.GetShieldTechCost(profile.ShieldLevel)
    if not DataService.SpendResearch(player, cost) then
        return false, "NOT_ENOUGH"
    end
    profile.ShieldLevel += 1
    return true
end

function DataService.GetShieldCooldown(player)
    local profile = profiles[player.UserId]
    return Config.GetEmergencyShieldCooldown(profile and profile.ShieldLevel or 0)
end

function DataService.ResetShieldCooldown(player)
    local profile = profiles[player.UserId]
    if not profile then return false end
    profile.ShieldReadyAt = 0
    return true
end

function DataService.AddSeasonXP(player, amount)
    local profile = DataService.EnsureDaily(player)
    if not profile then return false end
    profile.SeasonXP = math.max(0, math.floor(profile.SeasonXP + amount))
    return true
end

function DataService.RecordMissionProgress(player, missionId, amount)
    local profile = DataService.EnsureDaily(player)
    if not profile or profile.DailyCompleted[missionId] then return false end
    profile.DailyProgress[missionId] = math.max(0, math.floor((profile.DailyProgress[missionId] or 0) + amount))
    return true
end

function DataService.SetMissionCompleted(player, missionId)
    local profile = DataService.EnsureDaily(player)
    if not profile then return false end
    profile.DailyCompleted[missionId] = true
    return true
end

function DataService.HasSeasonPremium(player)
    local profile = profiles[player.UserId]
    return profile ~= nil and profile.PremiumSeasonId == Config.Season.Id
end

function DataService.UnlockSeasonPremium(player)
    local profile = profiles[player.UserId]
    if not profile then return false end
    profile.PremiumSeasonId = Config.Season.Id
    return true
end

function DataService.AddAbilityCharge(player, abilityId, amount)
    local profile = profiles[player.UserId]
    if not profile or not Config.Abilities[abilityId] then return false end
    profile.AbilityCharges[abilityId] = math.max(0, math.floor((profile.AbilityCharges[abilityId] or 0) + amount))
    return true
end

function DataService.ConsumeAbilityCharge(player, abilityId)
    local profile = profiles[player.UserId]
    if not profile or not Config.Abilities[abilityId] then return false end
    local charges = profile.AbilityCharges[abilityId] or 0
    if charges <= 0 then return false end
    profile.AbilityCharges[abilityId] = charges - 1
    return true
end

function DataService.GetAbilityCharges(player, abilityId)
    local profile = profiles[player.UserId]
    if not profile then return 0 end
    return math.max(0, math.floor((profile.AbilityCharges and profile.AbilityCharges[abilityId]) or 0))
end

function DataService.Save(player)
    local profile = profiles[player.UserId]
    if not profile then return true end
    profile.LastSeen = os.time()
    ensureSeason(profile)

    -- In an unpublished Studio place, data intentionally lasts only for this
    -- play session. Once published, this path automatically uses DataStore.
    if not dataStoreAvailable or not store then
        return true
    end

    local payload = {
        Research = profile.Research,
        SpeedLevel = profile.SpeedLevel,
        CapacityLevel = profile.CapacityLevel,
        IncomeLevel = profile.IncomeLevel,
        ShieldLevel = profile.ShieldLevel,
        Prestige = profile.Prestige,
        Specimens = clone(profile.Specimens),
        ShieldReadyAt = profile.ShieldReadyAt,
        LockdownReadyAt = profile.LockdownReadyAt,
        LastSeen = profile.LastSeen,

        SeasonId = profile.SeasonId,
        SeasonXP = profile.SeasonXP,
        SeasonFreeClaimed = profile.SeasonFreeClaimed,
        SeasonPremiumClaimed = profile.SeasonPremiumClaimed,
        PremiumSeasonId = profile.PremiumSeasonId,
        DailyMissionDay = profile.DailyMissionDay,
        DailyProgress = clone(profile.DailyProgress),
        DailyCompleted = clone(profile.DailyCompleted),
        AbilityCharges = clone(profile.AbilityCharges),
    }

    local ok, err = pcall(function()
        store:SetAsync(tostring(player.UserId), payload)
    end)
    if not ok then
        warn("ContainmentHeist DataStore save failed for", player.UserId, err)
    end
    return ok
end

function DataService.Release(player)
    DataService.Save(player)
    profiles[player.UserId] = nil
end

return DataService
