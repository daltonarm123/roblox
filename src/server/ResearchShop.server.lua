local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.Main.Services.DataService)

local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local toastEvent = remotes:WaitForChild("Toast")

local shopRequest = remotes:FindFirstChild("ShopRequest") or Instance.new("RemoteEvent")
shopRequest.Name = "ShopRequest"
shopRequest.Parent = remotes

local shopState = remotes:FindFirstChild("ShopState") or Instance.new("RemoteEvent")
shopState.Name = "ShopState"
shopState.Parent = remotes

local function toast(player, message)
    if player and player.Parent then
        toastEvent:FireClient(player, message)
    end
end

local function applySpeed(player)
    local profile = DataService.Get(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not profile or not humanoid then return end
    local speed = Config.GetWalkSpeed(profile.SpeedLevel)
    if player:GetAttribute("VIP") then speed *= 1.10 end
    humanoid.WalkSpeed = speed
end

local function sendState(player)
    local profile = DataService.Get(player)
    if not profile then return end
    shopState:FireClient(player, {
        Research = profile.Research,
        Speed = {
            Level = profile.SpeedLevel,
            MaxLevel = Config.SpeedUpgrade.MaxLevel,
            Cost = profile.SpeedLevel < Config.SpeedUpgrade.MaxLevel and Config.GetSpeedCost(profile.SpeedLevel) or -1,
        },
        Capacity = {
            Level = profile.CapacityLevel,
            MaxLevel = Config.CapacityUpgrade.MaxLevel,
            Cost = profile.CapacityLevel < Config.CapacityUpgrade.MaxLevel and Config.GetCapacityCost(profile.CapacityLevel) or -1,
            Slots = Config.GetCapacity(profile.CapacityLevel),
        },
        Income = {
            Level = profile.IncomeLevel,
            MaxLevel = Config.IncomeUpgrade.MaxLevel,
            Cost = profile.IncomeLevel < Config.IncomeUpgrade.MaxLevel and Config.GetIncomeUpgradeCost(profile.IncomeLevel) or -1,
            BonusPercent = math.floor((Config.GetIncomeMultiplier(profile.IncomeLevel) - 1) * 100 + 0.5),
        },
        ShieldTech = {
            Level = profile.ShieldLevel,
            MaxLevel = Config.ShieldTechUpgrade.MaxLevel,
            Cost = profile.ShieldLevel < Config.ShieldTechUpgrade.MaxLevel and Config.GetShieldTechCost(profile.ShieldLevel) or -1,
            Cooldown = DataService.GetShieldCooldown(player),
        },
    })
end

shopRequest.OnServerEvent:Connect(function(player, upgradeId)
    if type(upgradeId) ~= "string" then return end
    local profile = DataService.Get(player)
    if not profile then return end

    local ok, reason
    if upgradeId == "Speed" then
        ok, reason = DataService.BuySpeed(player)
        if ok then applySpeed(player) end
    elseif upgradeId == "Capacity" then
        ok, reason = DataService.BuyCapacity(player)
    elseif upgradeId == "Income" then
        ok, reason = DataService.BuyIncomeBoost(player)
    elseif upgradeId == "ShieldTech" then
        ok, reason = DataService.BuyShieldTech(player)
    else
        return
    end

    if ok then
        toast(player, "Upgrade purchased: " .. upgradeId .. "!")
    elseif reason == "NOT_ENOUGH" then
        toast(player, "Not enough Research for that upgrade.")
    elseif reason == "MAX" then
        toast(player, "That upgrade is already maxed.")
    end
    sendState(player)
end)

task.spawn(function()
    while true do
        task.wait(1)
        for _, player in ipairs(Players:GetPlayers()) do
            if DataService.Get(player) then
                sendState(player)
            end
        end
    end
end)
