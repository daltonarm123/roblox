local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local shopRequest = remotes:WaitForChild("ShopRequest")
local shopState = remotes:WaitForChild("ShopState")
local abilityRequest = remotes:WaitForChild("AbilityRequest")
local abilityState = remotes:WaitForChild("AbilityState")

local gui = Instance.new("ScreenGui")
gui.Name = "LabShopUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local openButton = Instance.new("TextButton")
openButton.AnchorPoint = Vector2.new(1, 0.5)
openButton.Position = UDim2.new(1, -18, 0.66, 0)
openButton.Size = UDim2.fromOffset(145, 44)
openButton.BackgroundColor3 = Color3.fromRGB(42, 120, 170)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "LAB SHOP"
openButton.TextSize = 16
openButton.Font = Enum.Font.GothamBlack
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 10)

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -18, 0.5, 0)
panel.Size = UDim2.fromOffset(390, 540)
panel.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
panel.BackgroundTransparency = 0.03
panel.Visible = false
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(72, 190, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.2

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(16, 10)
title.Size = UDim2.new(1, -70, 0, 32)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "LAB SHOP"
title.TextColor3 = Color3.fromRGB(95, 215, 255)
title.TextSize = 22
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

local researchLabel = Instance.new("TextLabel")
researchLabel.Position = UDim2.fromOffset(16, 48)
researchLabel.Size = UDim2.new(1, -32, 0, 28)
researchLabel.BackgroundTransparency = 1
researchLabel.TextXAlignment = Enum.TextXAlignment.Left
researchLabel.TextColor3 = Color3.fromRGB(105, 255, 175)
researchLabel.TextSize = 17
researchLabel.Font = Enum.Font.GothamBold
researchLabel.Text = "Research: 0"
researchLabel.Parent = panel

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(14, 82)
scroll.Size = UDim2.new(1, -28, 1, -96)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = Color3.fromRGB(90, 130, 160)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = panel
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function header(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 28)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 16
    label.Font = Enum.Font.GothamBlack
    label.Parent = scroll
    return label
end

local function makeCard()
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 66)
    button.BackgroundColor3 = Color3.fromRGB(27, 34, 44)
    button.TextColor3 = Color3.fromRGB(235, 242, 248)
    button.TextWrapped = true
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.Parent = scroll
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)
    local padding = Instance.new("UIPadding", button)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 10)
    return button
end

header("PERMANENT RESEARCH UPGRADES", Color3.fromRGB(105, 255, 175))

local upgradeButtons = {}
for _, id in ipairs({"Speed", "Capacity", "Income", "ShieldTech"}) do
    local button = makeCard()
    upgradeButtons[id] = button
    button.Activated:Connect(function()
        shopRequest:FireServer(id)
    end)
end

header("TEMPORARY ABILITIES", Color3.fromRGB(195, 125, 255))

local abilityButtons = {}
for _, id in ipairs({"StaticBurst", "JumpScare", "Cloak"}) do
    local button = makeCard()
    button.Size = UDim2.new(1, -4, 0, 78)
    abilityButtons[id] = button
    button.Activated:Connect(function()
        abilityRequest:FireServer(id)
    end)
end

local function costText(cost)
    if cost == -1 then return "MAX" end
    if cost >= 1000000 then return string.format("%.1fM R", cost / 1000000) end
    if cost >= 1000 then return string.format("%.1fK R", cost / 1000):gsub("%.0K", "K") end
    return tostring(cost) .. " R"
end

local latestResearch = 0
local latestShop = nil
local latestAbilities = nil

local function render()
    researchLabel.Text = "Research: " .. tostring(math.floor(latestResearch or 0))

    if latestShop then
        local speed = latestShop.Speed
        upgradeButtons.Speed.Text = string.format("SPEED  •  Lv.%d/%d\n+1.15 movement speed per level  •  %s", speed.Level, speed.MaxLevel, costText(speed.Cost))

        local capacity = latestShop.Capacity
        upgradeButtons.Capacity.Text = string.format("CAPACITY  •  %d slots  •  Lv.%d/%d\nAdd another containment slot  •  %s", capacity.Slots, capacity.Level, capacity.MaxLevel, costText(capacity.Cost))

        local income = latestShop.Income
        upgradeButtons.Income.Text = string.format("RESEARCH AMP  •  Lv.%d/%d  •  +%d%%\nPermanent passive income multiplier  •  %s", income.Level, income.MaxLevel, income.BonusPercent, costText(income.Cost))

        local shield = latestShop.ShieldTech
        upgradeButtons.ShieldTech.Text = string.format("SHIELD TECH  •  Lv.%d/%d\nEmergency shield cooldown: %ds  •  %s", shield.Level, shield.MaxLevel, shield.Cooldown, costText(shield.Cost))
    end

    if latestAbilities then
        for id, button in pairs(abilityButtons) do
            local state = latestAbilities[id]
            local config = Config.Abilities[id]
            if state and config then
                local useText
                if (state.CooldownRemaining or 0) > 0 then
                    useText = string.format("COOLDOWN %ds", state.CooldownRemaining)
                elseif (state.Charges or 0) > 0 then
                    useText = string.format("USE FREE CHARGE  •  %d stored", state.Charges)
                else
                    useText = string.format("BUY + USE  •  %d Research", config.ResearchCost)
                end
                button.Text = string.format("%s\n%s\n%s", config.Name, config.Description, useText)
            end
        end
    end
end

shopState.OnClientEvent:Connect(function(state)
    latestShop = state
    latestResearch = state.Research or latestResearch
    render()
end)

abilityState.OnClientEvent:Connect(function(state)
    latestAbilities = state.Abilities
    latestResearch = state.Research or latestResearch
    render()
end)

openButton.Activated:Connect(function()
    panel.Visible = true
    openButton.Visible = false
end)
close.Activated:Connect(function()
    panel.Visible = false
    openButton.Visible = true
end)
