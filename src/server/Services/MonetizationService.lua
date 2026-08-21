local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.DataService)

local MonetizationService = {}

local function ownsPass(player, passId)
    if not passId or passId <= 0 then
        return false
    end

    local success, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    return success and owns
end

function MonetizationService.RefreshPlayer(player)
    local multiplier = 1
    local gamePasses = Config.MONETIZATION.GamePasses

    if ownsPass(player, gamePasses.DoubleCash) then
        multiplier *= 2
    end
    if ownsPass(player, gamePasses.VIP) then
        multiplier *= 1.25
        player:SetAttribute("VIP", true)
    else
        player:SetAttribute("VIP", false)
    end

    player:SetAttribute("CashMultiplier", multiplier)
end

function MonetizationService.Init()
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
        if purchased then
            MonetizationService.RefreshPlayer(player)
        end
    end)

    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = game:GetService("Players"):GetPlayerByUserId(receiptInfo.PlayerId)
        if not player or not DataService.Get(player) then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local products = Config.MONETIZATION.DeveloperProducts
        local productId = receiptInfo.ProductId

        if products.Cash5000 > 0 and productId == products.Cash5000 then
            DataService.AddCash(player, 5000)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end

        if products.Cash50000 > 0 and productId == products.Cash50000 then
            DataService.AddCash(player, 50000)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end

        warn(string.format("[MonetizationService] Unknown developer product id %s", tostring(productId)))
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

return MonetizationService
