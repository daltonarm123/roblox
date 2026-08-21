local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local DataService = {}

local store = DataStoreService:GetDataStore(Config.DATASTORE_NAME)
local profiles = {}

local DEFAULT_DATA = {
    Version = 1,
    Cash = Config.STARTING_CASH,
    Scrap = 0,
    LifetimeCash = 0,
    Rebirths = 0,
    LastSeen = 0,
    Upgrades = {
        PickupPower = 0,
        SellBoost = 0,
        Storage = 0,
        AutoCrusher = 0,
    },
}

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, nestedValue in pairs(value) do
        copy[key] = deepCopy(nestedValue)
    end
    return copy
end

local function reconcile(target, template)
    for key, defaultValue in pairs(template) do
        if target[key] == nil then
            target[key] = deepCopy(defaultValue)
        elseif type(defaultValue) == "table" and type(target[key]) == "table" then
            reconcile(target[key], defaultValue)
        end
    end
end

function DataService.Load(player)
    local key = "Player_" .. player.UserId
    local loadedData

    local success, result = pcall(function()
        return store:GetAsync(key)
    end)

    if success and type(result) == "table" then
        loadedData = result
        reconcile(loadedData, DEFAULT_DATA)
    else
        loadedData = deepCopy(DEFAULT_DATA)
        if not success then
            warn(string.format("[DataService] Could not load %s; using session data: %s", player.Name, tostring(result)))
        end
    end

    loadedData.LastSeen = os.time()
    profiles[player] = loadedData
    return loadedData
end

function DataService.Get(player)
    return profiles[player]
end

function DataService.Save(player)
    local data = profiles[player]
    if not data then
        return true
    end

    data.LastSeen = os.time()
    local key = "Player_" .. player.UserId
    local snapshot = deepCopy(data)

    local success, err = pcall(function()
        store:UpdateAsync(key, function()
            return snapshot
        end)
    end)

    if not success then
        warn(string.format("[DataService] Could not save %s: %s", player.Name, tostring(err)))
    end

    return success
end

function DataService.Release(player)
    DataService.Save(player)
    profiles[player] = nil
end

function DataService.AddCash(player, amount)
    local data = profiles[player]
    if not data then
        return 0
    end

    amount = math.max(0, math.floor(tonumber(amount) or 0))
    data.Cash += amount
    data.LifetimeCash += amount
    return data.Cash
end

function DataService.SpendCash(player, amount)
    local data = profiles[player]
    if not data then
        return false
    end

    amount = math.max(0, math.floor(tonumber(amount) or 0))
    if data.Cash < amount then
        return false
    end

    data.Cash -= amount
    return true
end

function DataService.AddScrap(player, amount, capacity)
    local data = profiles[player]
    if not data then
        return 0
    end

    amount = math.max(0, math.floor(tonumber(amount) or 0))
    local room = math.max(0, capacity - data.Scrap)
    local added = math.min(room, amount)
    data.Scrap += added
    return added
end

function DataService.ClearScrap(player)
    local data = profiles[player]
    if not data then
        return 0
    end

    local amount = data.Scrap
    data.Scrap = 0
    return amount
end

function DataService.ResetForRebirth(player)
    local data = profiles[player]
    if not data then
        return
    end

    data.Rebirths += 1
    data.Cash = Config.STARTING_CASH
    data.Scrap = 0
    for upgradeName in pairs(data.Upgrades) do
        data.Upgrades[upgradeName] = 0
    end
end

return DataService
