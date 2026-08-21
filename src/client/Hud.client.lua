local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("ContainmentRemotes")
local stateEvent = remotes:WaitForChild("State")
local toastEvent = remotes:WaitForChild("Toast")

local function formatNumber(value)
    value = tonumber(value) or 0
    local suffixes = {
        {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"},
    }
    for _, entry in ipairs(suffixes) do
        if math.abs(value) >= entry[1] then
            local text = string.format("%.1f%s", value / entry[1], entry[2])
            return text:gsub("%.0([KMBT])", "%1")
        end
    end
    return tostring(math.floor(value))
end

local gui = Instance.new("ScreenGui")
gui.Name = "ContainmentHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local stats = Instance.new("Frame")
stats.Size = UDim2.fromOffset(300, 150)
stats.Position = UDim2.fromOffset(18, 18)
stats.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
stats.BackgroundTransparency = 0.12
stats.BorderSizePixel = 0
stats.Parent = gui
Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", stats)
stroke.Color = Color3.fromRGB(65, 227, 160)
stroke.Transparency = 0.35
stroke.Thickness = 1.5

local padding = Instance.new("UIPadding", stats)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 14)
padding.PaddingRight = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "CONTAINMENT HEIST"
title.TextColor3 = Color3.fromRGB(98, 255, 179)
title.Font = Enum.Font.GothamBlack
title.TextSize = 21
title.Parent = stats

local research = Instance.new("TextLabel")
research.Size = UDim2.new(1, 0, 0, 30)
research.Position = UDim2.fromOffset(0, 36)
research.BackgroundTransparency = 1
research.TextXAlignment = Enum.TextXAlignment.Left
research.Text = "Research: 0   (+0/s)"
research.TextColor3 = Color3.new(1, 1, 1)
research.Font = Enum.Font.GothamBold
research.TextSize = 19
research.Parent = stats

local collection = Instance.new("TextLabel")
collection.Size = UDim2.new(1, 0, 0, 26)
collection.Position = UDim2.fromOffset(0, 70)
collection.BackgroundTransparency = 1
collection.TextXAlignment = Enum.TextXAlignment.Left
collection.Text = "Contained: 0 / 3"
collection.TextColor3 = Color3.fromRGB(205, 216, 230)
collection.Font = Enum.Font.GothamMedium
collection.TextSize = 17
collection.Parent = stats

local upgrade = Instance.new("TextLabel")
upgrade.Size = UDim2.new(1, 0, 0, 42)
upgrade.Position = UDim2.fromOffset(0, 98)
upgrade.BackgroundTransparency = 1
upgrade.TextXAlignment = Enum.TextXAlignment.Left
upgrade.TextYAlignment = Enum.TextYAlignment.Top
upgrade.TextWrapped = true
upgrade.Text = "Speed: 250 R  •  Capacity: 1.8K R"
upgrade.TextColor3 = Color3.fromRGB(143, 183, 255)
upgrade.Font = Enum.Font.Gotham
upgrade.TextSize = 15
upgrade.Parent = stats

local carry = Instance.new("TextLabel")
carry.AnchorPoint = Vector2.new(0.5, 0)
carry.Position = UDim2.new(0.5, 0, 0, 24)
carry.Size = UDim2.fromOffset(430, 58)
carry.BackgroundColor3 = Color3.fromRGB(190, 35, 55)
carry.BackgroundTransparency = 0.08
carry.TextColor3 = Color3.new(1, 1, 1)
carry.Text = ""
carry.TextScaled = true
carry.Font = Enum.Font.GothamBlack
carry.Visible = false
carry.Parent = gui
Instance.new("UICorner", carry).CornerRadius = UDim.new(0, 14)

local objective = Instance.new("TextLabel")
objective.AnchorPoint = Vector2.new(0.5, 1)
objective.Position = UDim2.new(0.5, 0, 1, -24)
objective.Size = UDim2.new(0.78, 0, 0, 64)
objective.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
objective.BackgroundTransparency = 0.16
objective.TextColor3 = Color3.fromRGB(238, 244, 250)
objective.Text = "RAID CENTRAL CONTAINMENT → TAKE AN ANOMALY → ESCAPE TO YOUR GREEN PAD → PROTECT IT FROM OTHER PLAYERS"
objective.TextWrapped = true
objective.TextScaled = true
objective.Font = Enum.Font.GothamBold
objective.Parent = gui
Instance.new("UICorner", objective).CornerRadius = UDim.new(0, 14)
local objectivePadding = Instance.new("UIPadding", objective)
objectivePadding.PaddingLeft = UDim.new(0, 14)
objectivePadding.PaddingRight = UDim.new(0, 14)
objectivePadding.PaddingTop = UDim.new(0, 8)
objectivePadding.PaddingBottom = UDim.new(0, 8)

local toastHolder = Instance.new("Frame")
toastHolder.AnchorPoint = Vector2.new(1, 0)
toastHolder.Position = UDim2.new(1, -18, 0, 18)
toastHolder.Size = UDim2.fromOffset(390, 250)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = gui
local layout = Instance.new("UIListLayout", toastHolder)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

local function showToast(message)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 58)
    label.BackgroundColor3 = Color3.fromRGB(12, 18, 26)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextTransparency = 1
    label.TextWrapped = true
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(message)
    label.Parent = toastHolder
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 12)
    local p = Instance.new("UIPadding", label)
    p.PaddingLeft = UDim.new(0, 12)
    p.PaddingRight = UDim.new(0, 12)
    p.PaddingTop = UDim.new(0, 8)
    p.PaddingBottom = UDim.new(0, 8)

    TweenService:Create(label, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, TextTransparency = 0}):Play()
    task.delay(4.5, function()
        if label.Parent then
            local tween = TweenService:Create(label, TweenInfo.new(0.25), {BackgroundTransparency = 1, TextTransparency = 1})
            tween:Play()
            tween.Completed:Wait()
            label:Destroy()
        end
    end)
end

stateEvent.OnClientEvent:Connect(function(state)
    research.Text = string.format("Research: %s   (+%s/s)", formatNumber(state.Research), formatNumber(state.Income))
    collection.Text = string.format("Contained: %d / %d   •   Lab #%d", state.SpecimenCount or 0, state.Capacity or 0, state.BaseIndex or 0)

    local speedCost = state.SpeedCost == -1 and "MAX" or (formatNumber(state.SpeedCost) .. " R")
    local capacityCost = state.CapacityCost == -1 and "MAX" or (formatNumber(state.CapacityCost) .. " R")
    upgrade.Text = string.format("Blue pad: Speed %s   •   Purple pad: Capacity %s", speedCost, capacityCost)

    if state.Carrying then
        carry.Text = "⚠ CARRYING: " .. string.upper(state.Carrying) .. " — GET BACK TO YOUR LAB!"
        carry.Visible = true
        objective.Text = "ESCAPE SECURITY → REACH YOUR GREEN CONTAINMENT PAD → OTHER PLAYERS CAN STEAL IT AFTER YOU DEPOSIT"
    else
        carry.Visible = false
        objective.Text = "RAID CENTRAL CONTAINMENT → TAKE AN ANOMALY → ESCAPE TO YOUR GREEN PAD → RAID RIVAL LABS FOR BETTER LOOT"
    end
end)

toastEvent.OnClientEvent:Connect(showToast)

local camera = workspace.CurrentCamera
local function resize()
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    if viewport.X < 760 then
        stats.Size = UDim2.fromOffset(255, 142)
        carry.Size = UDim2.new(0.88, 0, 0, 54)
        objective.Size = UDim2.new(0.94, 0, 0, 72)
        toastHolder.Size = UDim2.new(0.86, 0, 0, 230)
    else
        stats.Size = UDim2.fromOffset(300, 150)
        carry.Size = UDim2.fromOffset(430, 58)
        objective.Size = UDim2.new(0.78, 0, 0, 64)
        toastHolder.Size = UDim2.fromOffset(390, 250)
    end
end

resize()
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end
