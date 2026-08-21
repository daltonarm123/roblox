local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local player = Players.LocalPlayer
local monetization = Config.Monetization
local passes = monetization.GamePasses
local products = monetization.DeveloperProducts
local suggested = monetization.SuggestedPrices

local gui = Instance.new("ScreenGui")
gui.Name = "RobuxShopUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Instance.new("TextButton")
openButton.Name = "OpenRobuxShop"
openButton.AnchorPoint = Vector2.new(1, 0.5)
openButton.Position = UDim2.new(1, -18, 0.52, 0)
openButton.Size = UDim2.fromOffset(145, 44)
openButton.BackgroundColor3 = Color3.fromRGB(25, 145, 85)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "R$ UPGRADES"
openButton.TextSize = 16
openButton.Font = Enum.Font.GothamBlack
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 10)

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -18, 0.5, 0)
panel.Size = UDim2.fromOffset(390, 540)
panel.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
panel.BackgroundTransparency = 0.03
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(75, 230, 150)
stroke.Thickness = 1.5
stroke.Transparency = 0.25

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -58, 0, 44)
title.Position = UDim2.fromOffset(16, 8)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "R$ UPGRADES"
title.TextColor3 = Color3.fromRGB(105, 255, 175)
title.TextSize = 22
title.Font = Enum.Font.GothamBlack
title.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 10)
close.Size = UDim2.fromOffset(38, 38)
close.BackgroundColor3 = Color3.fromRGB(40, 48, 60)
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "×"
close.TextSize = 25
close.Font = Enum.Font.GothamBold
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(14, 52)
status.Size = UDim2.new(1, -28, 0, 42)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(170, 185, 205)
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.Text = "Planned prices are shown during Studio testing. Live prices load from Roblox after product IDs are added."
status.Parent = panel

local holder = Instance.new("ScrollingFrame")
holder.Position = UDim2.fromOffset(14, 98)
holder.Size = UDim2.new(1, -28, 1, -112)
holder.BackgroundTransparency = 1
holder.BorderSizePixel = 0
holder.ScrollBarThickness = 5
holder.ScrollBarImageColor3 = Color3.fromRGB(70, 150, 110)
holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
holder.CanvasSize = UDim2.new()
holder.Parent = panel
local layout = Instance.new("UIListLayout", holder)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function configured(id)
    return type(id) == "number" and id > 0
end

local function makeProductCard(def)
    local isConfigured = configured(def.Id)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 64)
    button.BackgroundColor3 = isConfigured and Color3.fromRGB(24, 72, 54) or Color3.fromRGB(38, 43, 52)
    button.AutoButtonColor = isConfigured
    button.TextColor3 = isConfigured and Color3.new(1, 1, 1) or Color3.fromRGB(180, 185, 195)
    button.TextWrapped = true
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = holder
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)
    local padding = Instance.new("UIPadding", button)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 10)

    local shownPrice = def.Price
    local livePriceLoaded = false
    local function redraw()
        local suffix
        if isConfigured and livePriceLoaded then
            suffix = tostring(shownPrice) .. " R$"
        elseif isConfigured then
            suffix = "loading live price..."
        else
            suffix = tostring(def.Price) .. " R$ planned"
        end
        button.Text = string.format("%s  •  %s\n%s", def.Name, suffix, def.Description)
    end
    redraw()

    if isConfigured then
        task.spawn(function()
            local ok, info = pcall(function()
                return MarketplaceService:GetProductInfoAsync(def.Id, def.InfoType)
            end)
            if ok and info and info.PriceInRobux then
                shownPrice = info.PriceInRobux
                livePriceLoaded = true
                redraw()
            end
        end)
    end

    button.Activated:Connect(function()
        if not isConfigured then
            status.Text = string.format("%s is planned at %d R$. Publish the experience and create the matching product to enable it.", def.Name, def.Price)
            return
        end
        if def.InfoType == Enum.InfoType.GamePass then
            MarketplaceService:PromptGamePassPurchase(player, def.Id)
        else
            MarketplaceService:PromptProductPurchase(player, def.Id)
        end
    end)
end

-- Premium season access lives only in the Season panel so an already-premium
-- player cannot accidentally prompt a duplicate repeatable purchase.
local definitions = {
    {Name = "2× RESEARCH", Description = "Permanent passive Research multiplier.", Id = passes.DoubleResearch, InfoType = Enum.InfoType.GamePass, Price = suggested.DoubleResearch},
    {Name = "VIP", Description = "Permanent +10% movement speed and future VIP perks.", Id = passes.VIP, InfoType = Enum.InfoType.GamePass, Price = suggested.VIP},
    {Name = "+5,000 RESEARCH", Description = "Repeatable Research bundle.", Id = products.Research5000, InfoType = Enum.InfoType.Product, Price = suggested.Research5000},
    {Name = "+25,000 RESEARCH", Description = "Larger repeatable Research bundle.", Id = products.Research25000, InfoType = Enum.InfoType.Product, Price = suggested.Research25000},
    {Name = "INSTANT SHIELD RECHARGE", Description = "Reset your emergency shield cooldown immediately.", Id = products.InstantShieldRecharge, InfoType = Enum.InfoType.Product, Price = suggested.InstantShieldRecharge},
    {Name = "+1 STATIC BURST", Description = "Stores one free Static Burst use in your Lab Shop.", Id = products.StaticBurstCharge, InfoType = Enum.InfoType.Product, Price = suggested.StaticBurstCharge},
    {Name = "+1 BREACH SCARE", Description = "Stores one free Breach Scare use in your Lab Shop.", Id = products.JumpScareCharge, InfoType = Enum.InfoType.Product, Price = suggested.JumpScareCharge},
    {Name = "+1 PHASE CLOAK", Description = "Stores one free Phase Cloak use. Cloak cannot carry loot.", Id = products.CloakCharge, InfoType = Enum.InfoType.Product, Price = suggested.CloakCharge},
}

for _, def in ipairs(definitions) do
    makeProductCard(def)
end

openButton.Activated:Connect(function()
    panel.Visible = true
    openButton.Visible = false
end)

close.Activated:Connect(function()
    panel.Visible = false
    openButton.Visible = true
end)
