local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.Main.Services.DataService)

local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local toastEvent = remotes:WaitForChild("Toast")

local passes = Config.Monetization.GamePasses
local products = Config.Monetization.DeveloperProducts

local function toast(player, message)
    if player and player.Parent then
        toastEvent:FireClient(player, message)
    end
end

local function ownsPass(player, passId)
    if not passId or passId <= 0 then return false end
    local ok, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    return ok and result == true
end

local function refreshPasses(player)
    player:SetAttribute("DoubleResearch", ownsPass(player, passes.DoubleResearch))
    player:SetAttribute("VIP", ownsPass(player, passes.VIP))
end

local function applyVipSpeed(player)
    if not player:GetAttribute("VIP") then return end
    local profile = DataService.Get(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if profile and humanoid then
        humanoid.WalkSpeed = Config.GetWalkSpeed(profile.SpeedLevel) * 1.10
    end
end

local function setupPlayer(player)
    task.spawn(function()
        refreshPasses(player)
        task.wait(1)
        applyVipSpeed(player)
    end)

    player.CharacterAdded:Connect(function()
        task.wait(1)
        applyVipSpeed(player)
    end)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    if not wasPurchased then return end
    if gamePassId == passes.DoubleResearch then
        player:SetAttribute("DoubleResearch", true)
        toast(player, "2X RESEARCH unlocked permanently!")
    elseif gamePassId == passes.VIP then
        player:SetAttribute("VIP", true)
        applyVipSpeed(player)
        toast(player, "VIP unlocked — enjoy the permanent 10% movement bonus!")
    end
end)

-- Repeat purchases are granted only from ProcessReceipt. IDs remain zero until
-- you publish and create each product, so Studio testing cannot charge anyone.
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local profile = DataService.Get(player)
    if not profile then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local productId = receiptInfo.ProductId
    if products.Research5000 > 0 and productId == products.Research5000 then
        DataService.AddResearch(player, 5000)
        toast(player, "Purchase complete: +5,000 Research!")
    elseif products.Research25000 > 0 and productId == products.Research25000 then
        DataService.AddResearch(player, 25000)
        toast(player, "Purchase complete: +25,000 Research!")
    elseif products.InstantShieldRecharge > 0 and productId == products.InstantShieldRecharge then
        DataService.ResetShieldCooldown(player)
        toast(player, "Emergency Shield instantly recharged!")
    elseif products.SeasonPremium > 0 and productId == products.SeasonPremium then
        if not DataService.HasSeasonPremium(player) then
            DataService.UnlockSeasonPremium(player)
            toast(player, "PREMIUM SEASON TRACK unlocked! Earned premium tier rewards will be granted automatically.")
        else
            -- A product prompt should be hidden once owned, but still acknowledge a
            -- duplicate receipt safely instead of withholding a completed purchase.
            toast(player, "Premium season track is already active for this season.")
        end
    elseif products.StaticBurstCharge > 0 and productId == products.StaticBurstCharge then
        DataService.AddAbilityCharge(player, "StaticBurst", 1)
        toast(player, "+1 STATIC BURST charge added to your Lab Shop.")
    elseif products.JumpScareCharge > 0 and productId == products.JumpScareCharge then
        DataService.AddAbilityCharge(player, "JumpScare", 1)
        toast(player, "+1 BREACH SCARE charge added to your Lab Shop.")
    elseif products.CloakCharge > 0 and productId == products.CloakCharge then
        DataService.AddAbilityCharge(player, "Cloak", 1)
        toast(player, "+1 PHASE CLOAK charge added to your Lab Shop.")
    else
        warn("ContainmentHeist received an unknown developer product receipt:", productId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Main applies normal speed after a Research speed upgrade. Re-apply the VIP
-- multiplier so a pass owner never loses their bonus after buying an upgrade.
task.spawn(function()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            applyVipSpeed(player)
        end
        task.wait(1)
    end
end)
