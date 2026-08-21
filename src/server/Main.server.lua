local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.Services.DataService)
local EconomyService = require(script.Parent.Services.EconomyService)
local MonetizationService = require(script.Parent.Services.MonetizationService)
local WorldService = require(script.Parent.Services.WorldService)

local remotes = ReplicatedStorage:FindFirstChild("JunkyardRemotes") or Instance.new("Folder")
remotes.Name = "JunkyardRemotes"
remotes.Parent = ReplicatedStorage

local stateEvent = remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
stateEvent.Name = "State"
stateEvent.Parent = remotes

local actionEvent = remotes:FindFirstChild("Action") or Instance.new("RemoteEvent")
actionEvent.Name = "Action"
actionEvent.Parent = remotes

local requestState = remotes:FindFirstChild("RequestState") or Instance.new("RemoteFunction")
requestState.Name = "RequestState"
requestState.Parent = remotes

local actionTimes = {}

local function updateLeaderstats(player, state)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player

        local cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Parent = leaderstats

        local rebirths = Instance.new("IntValue")
        rebirths.Name = "Rebirths"
        rebirths.Parent = leaderstats
    end

    leaderstats.Cash.Value = state.Cash
    leaderstats.Rebirths.Value = state.Rebirths
end

local function pushState(player, message, success)
    local state = EconomyService.GetState(player)
    if not state then
        return
    end

    updateLeaderstats(player, state)
    stateEvent:FireClient(player, state, message, success)
end

local function canAct(player)
    local now = os.clock()
    local previous = actionTimes[player] or 0
    if now - previous < 0.1 then
        return false
    end
    actionTimes[player] = now
    return true
end

local function processAction(player, action, argument)
    if not DataService.Get(player) or not canAct(player) then
        return
    end

    local success, message
    if action == "CollectScrap" then
        success, message = EconomyService.CollectScrap(player)
    elseif action == "SellScrap" then
        success, message = EconomyService.SellScrap(player)
    elseif action == "BuyUpgrade" and type(argument) == "string" then
        success, message = EconomyService.BuyUpgrade(player, argument)
    elseif action == "Rebirth" then
        success, message = EconomyService.TryRebirth(player)
    else
        success, message = false, "Unknown action"
    end

    pushState(player, message, success)
end

local function hookWorldPrompts(world)
    for _, descendant in ipairs(world:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            descendant.Triggered:Connect(function(player)
                processAction(
                    player,
                    descendant:GetAttribute("Action"),
                    descendant:GetAttribute("UpgradeName")
                )
            end)
        end
    end
end

local function onPlayerAdded(player)
    DataService.Load(player)
    MonetizationService.RefreshPlayer(player)
    pushState(player, "Welcome to Junkyard Empire!", true)
end

local function onPlayerRemoving(player)
    DataService.Release(player)
    actionTimes[player] = nil
end

MonetizationService.Init()
local world = WorldService.Build()
hookWorldPrompts(world)

actionEvent.OnServerEvent:Connect(processAction)
requestState.OnServerInvoke = function(player)
    return EconomyService.GetState(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

task.spawn(function()
    while true do
        task.wait(Config.PASSIVE_TICK)
        for _, player in ipairs(Players:GetPlayers()) do
            if DataService.Get(player) then
                local paid = EconomyService.PayPassiveIncome(player)
                if paid > 0 then
                    pushState(player)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(Config.AUTOSAVE_INTERVAL)
        for _, player in ipairs(Players:GetPlayers()) do
            if DataService.Get(player) then
                task.spawn(DataService.Save, player)
            end
        end
    end
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        DataService.Save(player)
    end
end)
