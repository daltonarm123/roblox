local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local player = Players.LocalPlayer
local monetization = Config.Monetization

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
panel.Position = UDim2.new(1, -18, 0.52, 0)
panel.Size = UDim2.fromOffset(330, 390)
panel.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
panel.BackgroundTransparency = 0.04
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

local holder = Instance.new("Frame")
holder.Position = UDim2.fromOffset(14, 62)
holder.Size = UDim2.new(1, -28, 1, -112)
holder.BackgroundTransparency = 1
holder.Parent = panel
local layout = Instance.new("UIListLayout", holder)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local status = Instance.new("TextLabel")
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.new(0, 14, 1, -10)
status.Size = UDim2.new(1, -28, 0, 42)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextScaled = true
status.TextColor3 = Color3.fromRGB(170, 185, 205)
status.Font = Enum.Font.Gotham
status.Text = "Products become purchasable after we publish and add Creator Dashboard IDs."
status.Parent = panel

local function configured(id)
    return type(id) == "number" and id > 0
end

local function makeButton(text, subtitle, callback, isConfigured)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 54)
    button.BackgroundColor3 = isConfigured and Color3.fromRGB(24, 72, 54) or Color3.fromRGB(38, 43, 52)
    button.AutoButtonColor = isConfigured
    button.Text = text .. "\n" .. subtitle
    button.TextColor3 = isConfigured and Color3.new(1, 1, 1) or Color3.fromRGB(145, 150, 160)
    button.TextSize = 14
    button.TextWrapped = true
    button.Font = Enum.Font.GothamBold
    button.Parent = holder
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)

    button.Activated:Connect(function()
        if not isConfigured then
            status.Text = "Not for sale yet — we still need to publish the experience and create this product."
            return
        end
        callback()
    end)
end

local passes = monetization.GamePasses
local products = monetization.DeveloperProducts

makeButton("2× RESEARCH", "Permanent game pass", function()
    MarketplaceService:PromptGamePassPurchase(player, passes.DoubleResearch)
end, configured(passes.DoubleResearch))

makeButton("VIP", "Permanent +10% movement speed", function()
    MarketplaceService:PromptGamePassPurchase(player, passes.VIP)
end, configured(passes.VIP))

makeButton("+5,000 RESEARCH", "Repeatable developer product", function()
    MarketplaceService:PromptProductPurchase(player, products.Research5000)
end, configured(products.Research5000))

makeButton("+25,000 RESEARCH", "Repeatable developer product", function()
    MarketplaceService:PromptProductPurchase(player, products.Research25000)
end, configured(products.Research25000))

makeButton("INSTANT SHIELD RECHARGE", "Reset emergency shield cooldown", function()
    MarketplaceService:PromptProductPurchase(player, products.InstantShieldRecharge)
end, configured(products.InstantShieldRecharge))

openButton.Activated:Connect(function()
    panel.Visible = true
    openButton.Visible = false
end)

close.Activated:Connect(function()
    panel.Visible = false
    openButton.Visible = true
end)
