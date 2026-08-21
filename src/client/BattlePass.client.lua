local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local seasonState = remotes:WaitForChild("SeasonState")

local gui = Instance.new("ScreenGui")
gui.Name = "SeasonPassUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Instance.new("TextButton")
openButton.AnchorPoint = Vector2.new(1, 0.5)
openButton.Position = UDim2.new(1, -18, 0.38, 0)
openButton.Size = UDim2.fromOffset(145, 44)
openButton.BackgroundColor3 = Color3.fromRGB(205, 145, 35)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "SEASON 1"
openButton.TextSize = 16
openButton.Font = Enum.Font.GothamBlack
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 10)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -18, 0.5, 0)
panel.Size = UDim2.fromOffset(380, 520)
panel.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
panel.BackgroundTransparency = 0.03
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(235, 177, 62)
stroke.Thickness = 1.5
stroke.Transparency = 0.18

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(16, 10)
title.Size = UDim2.new(1, -70, 0, 32)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = Config.Season.Name
title.TextColor3 = Color3.fromRGB(255, 205, 85)
title.TextSize = 20
title.Font = Enum.Font.GothamBlack
title.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 10)
close.Size = UDim2.fromOffset(36, 36)
close.BackgroundColor3 = Color3.fromRGB(40, 48, 60)
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "×"
close.TextSize = 24
close.Font = Enum.Font.GothamBold
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local tierLabel = Instance.new("TextLabel")
tierLabel.Position = UDim2.fromOffset(16, 48)
tierLabel.Size = UDim2.new(1, -32, 0, 28)
tierLabel.BackgroundTransparency = 1
tierLabel.TextXAlignment = Enum.TextXAlignment.Left
tierLabel.TextColor3 = Color3.new(1, 1, 1)
tierLabel.TextSize = 18
tierLabel.Font = Enum.Font.GothamBold
tierLabel.Text = "Tier 0 / 20"
tierLabel.Parent = panel

local barBack = Instance.new("Frame")
barBack.Position = UDim2.fromOffset(16, 80)
barBack.Size = UDim2.new(1, -32, 0, 16)
barBack.BackgroundColor3 = Color3.fromRGB(34, 41, 52)
barBack.Parent = panel
Instance.new("UICorner", barBack).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(240, 174, 52)
barFill.Parent = barBack
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local xpLabel = Instance.new("TextLabel")
xpLabel.Position = UDim2.fromOffset(16, 100)
xpLabel.Size = UDim2.new(1, -32, 0, 22)
xpLabel.BackgroundTransparency = 1
xpLabel.TextXAlignment = Enum.TextXAlignment.Left
xpLabel.TextColor3 = Color3.fromRGB(175, 188, 205)
xpLabel.TextSize = 14
xpLabel.Font = Enum.Font.Gotham
xpLabel.Text = "0 / 100 Season XP"
xpLabel.Parent = panel

local nextReward = Instance.new("TextLabel")
nextReward.Position = UDim2.fromOffset(16, 126)
nextReward.Size = UDim2.new(1, -32, 0, 52)
nextReward.BackgroundColor3 = Color3.fromRGB(24, 30, 40)
nextReward.TextColor3 = Color3.fromRGB(220, 230, 240)
nextReward.TextWrapped = true
nextReward.TextSize = 13
nextReward.Font = Enum.Font.GothamMedium
nextReward.Text = "Next free reward\nLoading..."
nextReward.Parent = panel
Instance.new("UICorner", nextReward).CornerRadius = UDim.new(0, 8)

local missionHeader = Instance.new("TextLabel")
missionHeader.Position = UDim2.fromOffset(16, 186)
missionHeader.Size = UDim2.new(1, -32, 0, 24)
missionHeader.BackgroundTransparency = 1
missionHeader.TextXAlignment = Enum.TextXAlignment.Left
missionHeader.TextColor3 = Color3.fromRGB(105, 255, 175)
missionHeader.TextSize = 16
missionHeader.Font = Enum.Font.GothamBold
missionHeader.Text = "DAILY MISSIONS"
missionHeader.Parent = panel

local missionHolder = Instance.new("Frame")
missionHolder.Position = UDim2.fromOffset(16, 214)
missionHolder.Size = UDim2.new(1, -32, 0, 216)
missionHolder.BackgroundTransparency = 1
missionHolder.Parent = panel
local missionLayout = Instance.new("UIListLayout", missionHolder)
missionLayout.Padding = UDim.new(0, 6)
missionLayout.SortOrder = Enum.SortOrder.LayoutOrder

local missionRows = {}
for i = 1, 4 do
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = Color3.fromRGB(25, 31, 40)
    row.TextColor3 = Color3.fromRGB(220, 228, 238)
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextWrapped = true
    row.TextSize = 13
    row.Font = Enum.Font.GothamMedium
    row.Text = "Loading mission..."
    row.Parent = missionHolder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local padding = Instance.new("UIPadding", row)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 8)
    missionRows[i] = row
end

local premiumButton = Instance.new("TextButton")
premiumButton.AnchorPoint = Vector2.new(0, 1)
premiumButton.Position = UDim2.new(0, 16, 1, -16)
premiumButton.Size = UDim2.new(1, -32, 0, 58)
premiumButton.BackgroundColor3 = Color3.fromRGB(110, 70, 170)
premiumButton.TextColor3 = Color3.new(1, 1, 1)
premiumButton.TextWrapped = true
premiumButton.TextSize = 14
premiumButton.Font = Enum.Font.GothamBold
premiumButton.Text = "PREMIUM TRACK\n299 R$ planned"
premiumButton.Parent = panel
Instance.new("UICorner", premiumButton).CornerRadius = UDim.new(0, 10)

local productId = Config.Monetization.DeveloperProducts.SeasonPremium
local productConfigured = type(productId) == "number" and productId > 0
local displayPrice = Config.Season.SuggestedPremiumPrice

if productConfigured then
    task.spawn(function()
        local ok, info = pcall(function()
            return MarketplaceService:GetProductInfoAsync(productId, Enum.InfoType.Product)
        end)
        if ok and info and info.PriceInRobux then
            displayPrice = info.PriceInRobux
        end
    end)
end

premiumButton.Activated:Connect(function()
    if premiumButton:GetAttribute("Owned") then return end
    if not productConfigured then
        premiumButton.Text = string.format("PREMIUM TRACK • %d R$ PLANNED\nPublish + create product to enable", displayPrice)
        return
    end
    MarketplaceService:PromptProductPurchase(player, productId)
end)

seasonState.OnClientEvent:Connect(function(state)
    tierLabel.Text = string.format("Tier %d / %d%s", state.Tier or 0, state.MaxTier or 20, state.Premium and "  •  PREMIUM" or "")
    local ratio = math.clamp((state.XPIntoTier or 0) / math.max(1, state.XPPerTier or 100), 0, 1)
    barFill.Size = UDim2.fromScale(ratio, 1)
    xpLabel.Text = string.format("%d / %d XP to next tier  •  %d total", state.XPIntoTier or 0, state.XPPerTier or 100, state.XP or 0)
    nextReward.Text = string.format("NEXT FREE: %s\nNEXT PREMIUM: %s", state.NextFreeReward or "—", state.NextPremiumReward or "—")

    for i, row in ipairs(missionRows) do
        local mission = state.Missions and state.Missions[i]
        if mission then
            local prefix = mission.Completed and "✓ " or ""
            row.Text = string.format("%s%s  •  %d/%d  •  +%d XP", prefix, mission.Name, mission.Progress or 0, mission.Target or 0, mission.XP or 0)
            row.TextColor3 = mission.Completed and Color3.fromRGB(105, 255, 175) or Color3.fromRGB(220, 228, 238)
        end
    end

    premiumButton:SetAttribute("Owned", state.Premium == true)
    if state.Premium then
        premiumButton.BackgroundColor3 = Color3.fromRGB(45, 120, 82)
        premiumButton.Text = "PREMIUM TRACK UNLOCKED\nPremium rewards claim automatically"
    elseif productConfigured then
        premiumButton.BackgroundColor3 = Color3.fromRGB(110, 70, 170)
        premiumButton.Text = string.format("UNLOCK PREMIUM TRACK • %d R$\nExtra Research + ability charges every season tier", displayPrice)
    else
        premiumButton.BackgroundColor3 = Color3.fromRGB(65, 58, 80)
        premiumButton.Text = string.format("PREMIUM TRACK • %d R$ PLANNED\nPurchasing unlocks after publish", displayPrice)
    end
end)

openButton.Activated:Connect(function()
    panel.Visible = true
    openButton.Visible = false
end)
close.Activated:Connect(function()
    panel.Visible = false
    openButton.Visible = true
end)
